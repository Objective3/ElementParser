//
//  NSString_HTML.m
//  Thumbprint
//
//  Created by Lee Buck on 3/27/09.
//  Copyright 2009 Blue Bright Ventures. All rights reserved.
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.

//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.

//	Commercial licences without many of the obligations of GPL 
//	are available for a nomial fee at sales@touchtankapps.com.

//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "NSString_HTML.h"
#import "Element.h"
#import "CSSSelectorMatcher.h"
#import "ElementParser.h"
#import "TagChunk.h"
#import "CommentChunk.h"
#import "EntityChunk.h"
#import "ProcessingInstructionChunk.h"
#import "CDataChunk.h"
#import "DoctypeChunk.h"
#import "TxtChunk.h"

#define OUT_BUFFER_LENGTH 20000
#define MAX_READ_BUFFER_LENGTH 60000
static const NSDictionary* ENTITIES_MAP;



CFIndex lenThruOr(CFStringInlineBuffer* buffer, CFIndex index, const char a, const char b){
	CFIndex startIndex = index;
	unichar c;
	while ((c = CFStringGetCharacterFromInlineBuffer(buffer, index)) && (c!=a) && (c != b))
		index++;
	return index - startIndex;
}


unichar skipNonWhitespace(CFStringInlineBuffer* buffer, CFIndex* index){
	unichar c;
	for (;(c = CFStringGetCharacterFromInlineBuffer(buffer, *index)); (*index)++){
		if (c <= 32) 
			return c;
	}
	return 0;
}


unichar skipWhitespace(CFStringInlineBuffer* buffer, CFIndex* index){
	unichar c;
	for (;(c = CFStringGetCharacterFromInlineBuffer(buffer, *index)); (*index)++){
		if (c > 32) 
			return c;
	}
	return 0;
}


// allowed to start with / or close elements 
CFIndex lenToken(CFStringInlineBuffer* buffer, CFIndex index){
	CFIndex maxIndex  = buffer->rangeToBuffer.location + buffer->rangeToBuffer.length;
	CFIndex i;
	for (i = index; i < maxIndex; i++){
		unichar c = CFStringGetCharacterFromInlineBuffer(buffer, i);
		BOOL valid = ((c >= 'A') && (c <= 'Z')) || ((c >= 'a') && (c <= 'z')) || ((c >= '0') && (c <= '9')) || (c=='-') || (c=='_') || (c == ':');
		if ((valid == NO) && (i == index) && ((c == '/')))
			valid = YES;
		if (valid == NO)
			break;
	}
	return i - index;
}


CFIndex startsWithStr(CFStringInlineBuffer* buffer, CFIndex index, const char* prefix){
	CFIndex startIndex = index;
	while (*prefix){
		unichar c = CFStringGetCharacterFromInlineBuffer(buffer, index);
		if (c != *prefix)
			return 0;
		else 
			prefix++;
		index++;
	}
	return startIndex - index;
}


CFIndex lenEntityName(CFStringInlineBuffer* buffer, CFIndex index){
	CFIndex len = 1;
	index++; // first char is assumed to be a '&'
	unichar c;
	while (c = CFStringGetCharacterFromInlineBuffer(buffer, index++)){
		if (c==';') 
			return len + 1;
		if (((c < 'a') || (c > 'z')) && ((c < 'A') || (c > 'Z')) && ((c < '0') || (c > '9')) && (c != '#'))
			return NSNotFound;
		len++;
	}
	return 0;
}

CFIndex lenThruRespectingQuotes(CFStringInlineBuffer* buffer, CFIndex index, const char* suffix){
	CFIndex startIndex = index;
	int numCharsMatched = 0;
	const char* suffixStart = suffix;
	char openQuote = 0;
	while (*suffix){
		unichar c = CFStringGetCharacterFromInlineBuffer(buffer, index);
		if (c==0)
			return 0;
		else if (c == openQuote)
			openQuote = 0;
		else if ((c == *suffix) && (openQuote == 0)){
			suffix++;
			numCharsMatched++;
		}
		else {
			// reset the suffix ptr
			if (numCharsMatched){
				index -= numCharsMatched;
				suffix = suffixStart;
				numCharsMatched = 0;
			}
			if ((openQuote == 0) && ((c == '"') || (c == '\'')))
				openQuote = c;
		}
		index++;
	}
	return index - startIndex;
}

CFIndex lenThru(CFStringInlineBuffer* buffer, CFIndex index, const char* suffix){
	CFIndex startIndex = index;
	int numCharsMatched = 0;
	const char* suffixStart = suffix;
	while (*suffix){
		unichar c = CFStringGetCharacterFromInlineBuffer(buffer, index);
		if (c==0)
			return 0;
		else if (c == *suffix){
			suffix++;
			numCharsMatched++;
		}
		else if (suffix != suffixStart){
			// reset the suffix ptr
			index -= numCharsMatched;
			suffix = suffixStart;
			numCharsMatched = 0;
		}
		index++;
	}
	return index - startIndex;
}

unichar parseEntity(CFStringInlineBuffer* buffer, CFIndex index, CFIndex* len){
	//	assert(CFStringGetCharacterFromInlineBuffer(&buffer, index) == '&');
	if (startsWithStr(buffer, index+1, "gt;")){
		(*len) = 4;
		return '>';
	}
	else if (startsWithStr(buffer, index+1, "lt;")){
		(*len) = 4;
		return '<';
	}
	else if (startsWithStr(buffer, index+1, "amp;")){
		(*len) = 5;
		return '&';
	}
	else{
		(*len) = lenThru(buffer, index + 1, ";") + 1; 
		if (((*len) < 2) || ((*len) > 12)) return 0;
		unichar c = CFStringGetCharacterFromInlineBuffer(buffer, index + 1);
		if (c == '#'){
			unichar c = CFStringGetCharacterFromInlineBuffer(buffer, index + 2);
			if (c == 'x'){
				// hex entity
				NSString* hexString = [(NSString*)buffer->theString substringWithRange: NSMakeRange(index + 3, (*len) - 4)];
				return [hexString hexValue];
			}
			else{
				// decimal entity
				NSString* decString = [(NSString*)buffer->theString substringWithRange: NSMakeRange(index + 2, (*len) - 3)];
				return CFStringGetIntValue((CFStringRef)decString);
			}
		}
		else{ 
			//named enityt
			if (ENTITIES_MAP == nil)
				ENTITIES_MAP = [[NSDictionary alloc] initWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"HTML Entities" ofType: @"plist"]];
			if (!ENTITIES_MAP) return 0;
			NSString* key = [(NSString*)buffer->theString substringWithRange: NSMakeRange(index + 1, (*len) - 2)];
			NSString* result = [ENTITIES_MAP objectForKey: key];
			return (result) ? [result characterAtIndex: 0] : 0;
		}
	}
	return 0;
}


/* 
 assumes starting at the '<' of '<!DOCTYPE'
 known limitations
 1. will get confused if any of the internal decls (or comments, etc) have an embedded '>'
 2. will get confused if public identifier or system id have a '>' or a '[' in them
 */
CFIndex lenDoctype(CFStringInlineBuffer* buffer, CFIndex index){
	CFIndex startIndex = index;
	index += 9;
	CFIndex len = lenThruOr(buffer, index, '>', '[');
	unichar c = CFStringGetCharacterFromInlineBuffer(buffer, index + len);
	if (c == '>') //no internal decls
		return len + 10;

	// skip thru the internal decls / pe references
	while ((c = skipWhitespace(buffer, &index)) != ']'){
		if (c == '<')//elementdecl | AttlistDecl | EntityDecl | NotationDecl | PI | Comment
			len = lenThru(buffer, index, ">");
		else if (c == '%')//PEReference
			len = lenThru(buffer, index, ";");
		if (len < 0) return 0; //end of decl not found, fail				
		index += len;
	}
	
	if (!c) return 0; // ran out of buffer
	
	// found end of internal subset, just need the closing '>'
	
	index++;
	
	c = skipWhitespace(buffer, &index);
	if (c != '>') return 0; // ran out of buffer
	
	return index - startIndex + 1;
}

NSString* createStringFromBuffer(CFStringInlineBuffer* buffer, CFIndex index, CFIndex length){
	return (NSString*) CFStringCreateWithSubstring(NULL, buffer->theString, CFRangeMake(buffer->rangeToBuffer.location + index, length));
}

@implementation NSString (HTML)

-(int)hexValue{
	int base = 16;
	int result = 0;
	for (int i = 0; i < [self length]; i++){
		unichar c = [self characterAtIndex: i];
		if ((c >= '0') && (c <= '9'))
			result = (result * base) + (c - '0');
		else if ((c >= 'A') && (c <= 'F'))
			result = (result * base) + (c - 'A' + 10);
		else if ((c >= 'a') && (c <= 'f'))
			result = (result * base) + (c - 'a' + 10);
		else
			return result;
	}
	return result;
}

-(NSString*)stringByReplacingEntitiesInRange:(NSRange)range{
	int bufferLength = range.length;
	unichar *outBuffer = malloc(sizeof(unichar) * bufferLength);
	CFIndex index = 0;
	int writeIndex = 0;
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer((CFStringRef)self, &buffer, CFRangeMake(range.location, range.length));

	while (index < range.length){
		unichar c = CFStringGetCharacterFromInlineBuffer(&buffer, index);
		CFIndex len;
		unichar entity = (c == '&') ? parseEntity(&buffer, index, &len) : 0;
		if (entity){
			outBuffer[writeIndex++] = entity;
			index += len;
		}
		else {
			outBuffer[writeIndex++] = c;
			index++;
		}
	}
	NSString* result = [NSString stringWithCharacters: outBuffer length: writeIndex];
	free(outBuffer);
	return result;
}

-(NSString*)stringByReplacingEntities{
	return [self stringByReplacingEntitiesInRange: NSMakeRange(0, [self length])];
}


-(NSDictionary*)parseElementAttributesWithRange:(NSRange) range caseSensative:(BOOL)caseSensative{
	NSMutableDictionary* attributes = [[[NSMutableDictionary alloc] initWithCapacity: 8] autorelease];

	CFStringInlineBuffer localBuffer;
	CFStringInitInlineBuffer((CFStringRef)self, &localBuffer, CFRangeMake(range.location, range.length));
	
	CFIndex index = 1; // skip the leading '<'
	
	unichar c = skipNonWhitespace(&localBuffer, &index);
	
	while (c){
		NSString* attrName;
		NSString* attrValue;

		c = skipWhitespace(&localBuffer, &index);
		if (c == '/'){
			//the empty tag char at the end
			index++;
			break;
		}
		CFIndex tokenLen = lenToken(&localBuffer, index);
		if (tokenLen == 0)
			break;
		attrName = [self substringWithRange: NSMakeRange(index + localBuffer.rangeToBuffer.location, tokenLen)];
		index += [attrName length];
		c = skipWhitespace(&localBuffer, &index);
		if (c == '='){
			index++;//skip the =
			c = skipWhitespace(&localBuffer, &index);
			NSRange valueRange;
			if (c=='"'){
				CFIndex valueLen = lenThru(&localBuffer, index + 1, "\"");
				valueRange = NSMakeRange(index + localBuffer.rangeToBuffer.location + 1, valueLen - 1);
				index += 2;
			}
			else if (c=='\''){
				CFIndex valueLen = lenThru(&localBuffer, index + 1, "'");
				valueRange = NSMakeRange(index + localBuffer.rangeToBuffer.location + 1, valueLen - 1);
				index += 2;
			}
			else{
				CFIndex tokenLen = lenToken(&localBuffer, index);
				valueRange = NSMakeRange(index + localBuffer.rangeToBuffer.location, tokenLen);
			}
			attrValue = [self stringByReplacingEntitiesInRange: valueRange];
			[attributes setObject: attrValue forKey: caseSensative ? attrName : [attrName lowercaseString]];
			index += valueRange.length;
		}
		else{
			[attributes setObject: [NSNull null] forKey: caseSensative ? attrName : [attrName lowercaseString]];
		}
	}
	return attributes;
}


static inline int moveBufferToIndex(CFStringInlineBuffer *buffer, CFIndex index){
	CFIndex lengthLeftInString = CFStringGetLength(buffer->theString) - index;
	if (!lengthLeftInString) {
//		NSLog(@"done with string");
		return false;		
	}
	int bufferLength = MIN(lengthLeftInString, MAX_READ_BUFFER_LENGTH);
	CFRange range = CFRangeMake(index, bufferLength);
	if (range.location + range.length == buffer->rangeToBuffer.location + buffer->rangeToBuffer.length){
//		NSLog(@"end of string already buffered");
		return false;
	}
	CFStringInitInlineBuffer(buffer->theString, buffer, range);
//	if(range.location)
//		NSLog(@"moved buffer beyond 0");
	return true;
}

+(void)parseHTML:(NSString*)source delegate:(id)delegate selector:(SEL)selector context: (void*) context index:(int*)sourceIndex partial:(BOOL)partial{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	ElementParser* parser = ([delegate respondsToSelector:@selector(isKindOfClass:)] && [delegate isKindOfClass: [ElementParser class]]) ? delegate : nil;
	CFIndex index = *sourceIndex;
	CFIndex maxSourceIndex = [source length];
	CFStringInlineBuffer buffer;
	buffer.theString = (CFStringRef)source;
	buffer.rangeToBuffer.location = buffer.rangeToBuffer.length = 0;
	
	TagChunk* tag = [[TagChunk alloc] initWithString: source range: NSMakeRange(0,0) tagName: nil];
	CommentChunk* comment = [[CommentChunk alloc] initWithString: source range: NSMakeRange(0,0)];
	EntityChunk* entity = [[EntityChunk alloc] initWithString: source range: NSMakeRange(0,0)];
	DoctypeChunk* doctype = [[DoctypeChunk alloc] initWithString: source range: NSMakeRange(0,0)];
	ProcessingInstructionChunk* pi = [[ProcessingInstructionChunk alloc] initWithString: source range: NSMakeRange(0,0)];
	CDataChunk* cdata = [[CDataChunk alloc] initWithString: source range: NSMakeRange(0,0)];
	TxtChunk* text = [[TxtChunk alloc] initWithString: source range: NSMakeRange(0,0)];

	BOOL delegateWantsToContinue = YES;
	unichar c;
	
	while (delegateWantsToContinue && moveBufferToIndex(&buffer, buffer.rangeToBuffer.location + index)){
		index = 0;

		while (delegateWantsToContinue && (c = CFStringGetCharacterFromInlineBuffer(&buffer, index))){
						
			int tagLen;
			int len = 0;
			int interior;
			Chunk* chunk = nil;
			Chunk* partialChunk = nil;

			if (c == '<'){
				if (tagLen = lenToken(&buffer, index + 1)){
					interior = lenThruRespectingQuotes(&buffer, index + tagLen + 1, ">") + tagLen - 1;
					if (interior > 0){
						tag.tagName = createStringFromBuffer(&buffer, index + 1, tagLen);
						[tag.tagName release];
						chunk = tag;
						len = interior + 2;
					}
					else 
						partialChunk = tag;
				}
				else if (startsWithStr(&buffer, index + 1, "!--")){
					interior = lenThru(&buffer, index + 4, "-->")-3;
					if (interior > 0){
						chunk = comment;				
						len = interior + 7;
					}
					else 
						partialChunk = comment;
				}
				else if (startsWithStr(&buffer, index + 1, "![CDATA[")){
					interior = lenThru(&buffer, index + 9, "]]>")-3;
					if (interior > 0){
						chunk = cdata;				
						len = interior + 12;
					}
					else 
						partialChunk = cdata;
				}
				else if (startsWithStr(&buffer, index + 1, "?")){
					interior = lenThru(&buffer, index + 2, ">")-1;
					if (interior > 0){
						chunk = pi;				
						len = interior + 3;
					}
					else 
						partialChunk = pi;
				}
				else if (startsWithStr(&buffer, index + 1, "!DOCTYPE")){
					interior = lenDoctype(&buffer, index + 9) - 1;
					if (interior > 0){
						chunk = doctype;				
						len = interior + 10;
					}
					else 
						partialChunk = doctype;
				}
				else 
					partialChunk = tag;
			}
			else if (c == '&'){
				// complicated by the fact that what appears to be an entity may infact just be text
				CFIndex entityLen = lenEntityName(&buffer, index);
				if (entityLen == NSNotFound){
					len = lenThruOr(&buffer, index + 1, '<', '&') + 1;
					chunk = text;
				}
				else if (entityLen > 0){
					chunk = entity;				
					len = entityLen;
				}
				else
					partialChunk = entity;
			}
			else{
				len = lenThruOr(&buffer, index + 1, '<', '&') + 1;
				chunk = text;
			}
			
			if (partialChunk){ // recover from a partial chunk
				BOOL bytesLeftBeyondBuffer = maxSourceIndex > (buffer.rangeToBuffer.location + buffer.rangeToBuffer.length);
				if (bytesLeftBeyondBuffer || partial) 
					break; // go get more bytes in the buffer / or exit 
				
				// recover by emiting as text
				len = lenThruOr(&buffer, index + 1, '<', '&') + 1;
				chunk = text;

				NSString* fragment = [source substringWithRange: NSMakeRange(buffer.rangeToBuffer.location + index, MIN(8, [source length] - buffer.rangeToBuffer.location + index))];
				[parser info: [NSString stringWithFormat: @"Unable to parse '%@' as %@", fragment, [[partialChunk class] humanName]] atIndex: buffer.rangeToBuffer.location + index];
			}
			
			// hand the chunk to the delgate
			chunk.range = NSMakeRange(index + buffer.rangeToBuffer.location, len);
//			NSLog(@"%@: %@", [[chunk class] humanName], [source substringWithRange: chunk.range]);
			chunk.buffer = &buffer;		
			delegateWantsToContinue = [delegate performSelector: selector withObject: chunk withObject: context] != nil;
			index += len;

			assert(index > 0);
		}
	}
	
	if (!delegateWantsToContinue)
		[parser info: @"delegate stopped the parsing" atIndex: buffer.rangeToBuffer.location + index];

	[tag release];
	[comment release];
	[entity release];
	[pi release];
	[cdata release];
	[doctype release];
	[text release];

	*sourceIndex = index + buffer.rangeToBuffer.location;
	[pool release];
}


+(void)parseHTML:(NSString*) source delegate:(id)delegate selector:(SEL)selector context: (void*) context{
	int index = 0;
	[self parseHTML: source delegate: delegate selector: selector context: context index: &index partial: NO];		
	NSAssert2(index == [source length], @"%i != %i", index, [source length]);
} 

typedef struct{
	NSMutableString* result;
	unichar* outBuffer;
	int outBufferLength;
	int writeIndex;
	BOOL inScriptElement;
	BOOL inWhite;
	BOOL inPara;
} StripTagsContext;


-(NSString*)stripTags{
	NSMutableString* result = [NSMutableString stringWithCapacity: [self length]];
	StripTagsContext context;
	context.result = result;
	context.outBufferLength = MIN([self length], OUT_BUFFER_LENGTH);
	context.outBuffer = malloc(sizeof(unichar) * context.outBufferLength);
	context.writeIndex = 0;
	context.inScriptElement = NO;
	context.inWhite = YES;
	context.inPara = YES;
	
	[NSString parseHTML: self delegate: self selector:@selector(chunk:context:) context: &context];

	if (context.writeIndex > 0)
		CFStringAppendCharacters((CFMutableStringRef)result, context.outBuffer, context.writeIndex);

	free(context.outBuffer);

	return result;
}

-(id)chunk:(Chunk*)chunk context:(StripTagsContext*)context{
	//write the  outBuffer if there isn't enough room for the  whole chunk
	if (context->writeIndex + chunk.range.length > context->outBufferLength){
		CFStringAppendCharacters((CFMutableStringRef)context->result, context->outBuffer, context->writeIndex);
		context->writeIndex = 0;
		if (chunk.range.length > context->outBufferLength){
			// need to grow buffer
			free(context->outBuffer);
			context->outBufferLength = chunk.range.length;
			context->outBuffer = malloc(sizeof(unichar) * context->outBufferLength);
		}
	}
	assert(context->writeIndex + chunk.range.length <= context->outBufferLength);
		
	CFRange bufferRangeToAppend = CFRangeMake(0, 0);
	CFStringInlineBuffer* buffer = chunk.buffer;

	if ([chunk isKind: ChunkKindTag]){
		TagChunk* tag = (TagChunk*)chunk;
		if (context->inScriptElement == YES){
			if ([tag tagNameEquals: @"/script"])
				context->inScriptElement = NO;
		}
		else if ([tag tagNameEquals: @"script"])
			context->inScriptElement = YES;
		else if ([tag emitsNewLineInContents]){
			if (!context->inPara){//dont do double paras
				context->outBuffer[context->writeIndex++] = '\n';
				context->outBuffer[context->writeIndex++] = '\n';
				context->inWhite = YES;
				context->inPara = YES;
			}
		}
	}
	else if (context->inScriptElement == YES)
		; // do nothing
	else if ([chunk isKind: ChunkKindText]){
		bufferRangeToAppend = chunk.rangeInBuffer;
	}
	else if ([chunk isKind: ChunkKindCData]){
		bufferRangeToAppend = [chunk interiorRangeInBuffer];
	}
	else if ([chunk isKind: ChunkKindEntity]){
		CFRange rangeInBuffer = [chunk rangeInBuffer];
		unichar entity = parseEntity(chunk.buffer, rangeInBuffer.location, &rangeInBuffer.length);		
		if (entity){
			context->outBuffer[context->writeIndex++] = entity;
			context->inWhite = NO;
		}
		else{
			//we regurgitate unrecognized entities
			bufferRangeToAppend = rangeInBuffer;
		}
	}

	int maxBufferIndex = bufferRangeToAppend.location + bufferRangeToAppend.length;
	for (int bufferIndex = bufferRangeToAppend.location; bufferIndex < maxBufferIndex; bufferIndex ++){
		unichar c = CFStringGetCharacterFromInlineBuffer(buffer, bufferIndex);
		if (c <= 32){
			if (!context->inWhite)
				context->outBuffer[context->writeIndex++] = 32;
			context->inWhite = YES;
		}
		else{
			context->outBuffer[context->writeIndex++] = c;
			context->inWhite = NO;
			context->inPara = NO;
		}
	}
	return self;
}

-(Element*)element{
	CFStringInlineBuffer buffer;
	CFStringInitInlineBuffer((CFStringRef)self, &buffer, CFRangeMake(0, [self length]));
	int len = lenToken(&buffer, 1);
	NSString* tagName = createStringFromBuffer(&buffer, 1, len);
	Element* result = [[[Element alloc] initWithString: self range: NSMakeRange(0, [self length])  tagName: tagName] autorelease];
	[tagName release];
	return result;
}


-(NSString*)stringByAddingPercentEscaping{
	return [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, NULL, kCFStringEncodingUTF8) autorelease];
}

-(NSString*)stringByRemovingPercentEscaping{
	return [(NSString*)CFURLCreateStringByReplacingPercentEscapes(NULL, (CFStringRef)self, NULL) autorelease];
}

// TODO Handle different encodings
+ (NSStringEncoding) encodingForContentType:(NSString *)contentType{
	if ([contentType rangeOfString: @"utf-8" options: NSCaseInsensitiveSearch].location != NSNotFound)
		return NSUTF8StringEncoding;
	else if ([contentType rangeOfString: @"iso-8859-1" options: NSCaseInsensitiveSearch].location != NSNotFound)
		return NSISOLatin1StringEncoding;
	else if ([contentType rangeOfString: @"windows-1252" options: NSCaseInsensitiveSearch].location != NSNotFound)
		return NSWindowsCP1252StringEncoding;
	else if ([contentType rangeOfString: @"encoding=" options: NSCaseInsensitiveSearch].location != NSNotFound)
		NSLog(@"unknown encoding: %@", contentType);
	return NSISOLatin1StringEncoding;
}


@end
