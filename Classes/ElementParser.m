//
//  ElementParser.m
//  Thumbprint
//
//  Created by Lee Buck on 4/20/09.
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

#import "ElementParser.h"
#import "NSString_HTML.h"
#import "Chunk.h"
#import "TagChunk.h"
#import "CSSSelectorMatcher.h"

static NSSet* HTML_TAGS_THAT_SHOULD_BE_EMPTY;


@interface ElementParser()

@property (nonatomic, assign) Element* lastOpened;
@property (nonatomic, assign) Element* lastClosedBeforeOpen;
@property (nonatomic, retain) DocumentRoot* root;
@property (nonatomic, retain) Chunk* lastChunk;

-(void)closeAllTags;
-(void)prepareParseWithString:(NSString*)string;
-(void)parseMoreWithPartial:(BOOL)partial;

@end


@implementation ElementParser

@synthesize root, lastOpened, lastClosedBeforeOpen, lastChunk, delegate, mode;

+(void)initialize{
	HTML_TAGS_THAT_SHOULD_BE_EMPTY = [[NSSet alloc] initWithObjects: @"img", @"meta", @"br", @"hr", @"area", @"base", @"basefont", @"col", @"frame", @"input", @"isindex", @"link", @"param", nil];
}

-(id)init{
	self = [super init];
	tagStack = [[NSMutableArray alloc] initWithCapacity: 24];
	mode = ElementParserModeHTML;
	return self;
}

-(void)dealloc{
	[tagStack release];
	[root release];
	[lastChunk release];
	if (callbackMethods){
		CFRelease(callbackMethods);
		[callbackMatchers release];
	}
	[super dealloc];	
}

-(DocumentRoot*)parseHTML:(NSString*)source{
	if (!source) return nil;
	self.mode = ElementParserModeHTML;
	[self prepareParseWithString: source];
	[self parseMoreWithPartial: NO];
	[self closeAllTags];
	return root;
}

-(DocumentRoot*)parseXML:(NSString*)source{
	if (!source) return nil;
	self.mode = ElementParserModeXML;
	[self prepareParseWithString: source];
	[self parseMoreWithPartial: NO];
	[self closeAllTags];
	return root;
}


-(DocumentRoot*)beginParsing{
	NSMutableString* source = [NSMutableString string];
	[self prepareParseWithString: source];
	return root;
}

-(void)continueParsingString:(NSString*)moreString{
	[(NSMutableString*)self.source appendString:moreString];
	[self parseMoreWithPartial: YES];
}

-(void)finishParsing{
	[self parseMoreWithPartial: NO];
	[self closeAllTags];	
}

-(NSString*)source{
	return root.source;
}

-(void)prepareParseWithString:(NSString*)string{
	root = [[DocumentRoot alloc] initWithString: string range: NSMakeRange(0,0)];
	lastOpened = root;
	[tagStack removeAllObjects];
	[tagStack addObject: root];
}

-(void)parseMoreWithPartial:(BOOL)partial{
	int index = lastChunk ? NSMaxRange(lastChunk.range) : 0;
	NSString* source = [root source];
	root.contentsLength = [source length];
	[NSString parseHTML: source delegate: self selector: @selector(buildElementTreeWithChunk:context:) context: self index: &index partial: partial];
}


-(Element*)parentElement{
	return [tagStack objectAtIndex: [tagStack count] - 1];
}

-(void)matchElement:(Element*)element{
	for (int i = 0; i < [callbackMatchers count]; i++){
		CSSSelectorMatcher* matcher = [callbackMatchers objectAtIndex: i];
		BOOL matchComplete = [matcher matchElement: element];
		if (matchComplete){
			SEL selector = (SEL)CFArrayGetValueAtIndex(callbackMethods, i);
			NSObject* domainObject = [delegate performSelector: selector withObject: element]; 
			if (domainObject)
				element.domainObject = domainObject;
		}
	}
}

// nil is a valid value... closed first open tag
-(void)closeElementWithTag:(TagChunk*) tag{
	int depthIndex;
	for (depthIndex = [tagStack count] - 1; depthIndex > 0; depthIndex--){
		// crawl up stack to find matching element
		Element* stackElement = [tagStack objectAtIndex: depthIndex];
		if (!tag || [tag closesTag: stackElement])
			break;
	}
	if (depthIndex > 0){
		Element* closedElement;
		// close everything up to found element
		while ([tagStack count] > depthIndex){//int ii=[tagStack count] - 1; ii >= depth; ii--
			closedElement = [tagStack lastObject];
			closedElement.contentsLength = 
				(tag == nil) ? lastChunk.range.location - NSMaxRange(closedElement.range) : 
				(tag == closedElement) ? 0 : 
				tag.range.location - NSMaxRange(closedElement.range);
			if(!tag && closedElement.contentsLength == 0)
				[self warning: ElementParserGeneralError description:@"Contents may not be right" chunk: closedElement];
//			NSLog(@"Close %@", [closedElement description]);
			self.lastClosedBeforeOpen = closedElement;
			[tagStack removeObjectsInRange: NSMakeRange([tagStack count] - 1, 1)];
			if (delegate && callbackMatchers)
				[self matchElement: closedElement];
		}
//		self.lastClosedBeforeOpen = closedElement;
//		[tagStack removeObjectsInRange: NSMakeRange(i, [tagStack count] - i)];
	}
	else{
		// orphan close tag - ignore
	}
}

-(void)openElement:(Element*) element{
//	NSLog(@"Open %@", [element description]);
	element.parent = [self parentElement];
	lastOpened.nextElement = element;
	self.lastClosedBeforeOpen.nextSybling = element;
	[tagStack addObject: element];
	self.lastOpened = element;
	self.lastClosedBeforeOpen = nil;
}

-(void)closeAllTags{
	for (int i = [tagStack count] - 1; i >= 0; i--){
		Element* stackElement = [tagStack objectAtIndex: i];
		if (i > 0)
			[self warning: ElementParserTagNotClosedError description:@"document left tag open" chunk: stackElement];
		[self closeElementWithTag: nil];
	}
}

-(void)info:(NSString*)info atIndex:(int)sourceIndex{
	NSLog(@"INFO [index: %i]: %@", sourceIndex, info);
}

-(void)warning:(int)code description:(NSString*)description chunk: (Chunk*)chunk{
	NSLog(@"WARN [index: %i]: %@\n%@", chunk.range.location, description, [chunk description]);
	/* subclasses should do this work if they want to do something with the warnings
	NSMutableDictionary* info = [NSMutableDictionary dictionaryWithCapacity: 2];
	if (description)
		[info addObject: description forKey: NSLocalizedDescriptionKey];
	if (chunk)
		[info addObject: chunk forKey: ElementParserErrorChunk];
	NSError* error = [NSError errorWithDomain: ElementParserErrorDomain code: code userInfo: info];
	 */
}

-(BOOL)shouldBeEmptyElement:(Element*)element{
	if (mode == ElementParserModeXML) return NO;
	BOOL result =  [HTML_TAGS_THAT_SHOULD_BE_EMPTY containsObject: [element key]];
	return result;
}

-(id)buildElementTreeWithChunk:(Chunk*)chunk context:(void*)builder{
/*
	used to hunt down problem strings in example documents
	BOOL breakpoint = [[chunk description] rangeOfString: @""].location != NSNotFound;
	if (breakpoint)
		NSLog(@"found breakpoint");
*/	
	self.lastChunk = chunk;
	TagChunk* tag = [chunk isKind: ChunkKindTag] ? (TagChunk*) chunk : nil;

	if (![chunk isKind: ChunkKindText] && ![tag isCloseTag]) 
		[self parentElement].containsMarkup = YES;
	
	if (!tag)
		return self;
	else if ([tag isCloseTag])
		[self closeElementWithTag: tag];
	else {
		Element* element = [[Element alloc] initWithTag: tag caseSensative: mode == ElementParserModeXML];
		if ([element isEmptyTag] || [self shouldBeEmptyElement: element]){
			[self openElement: element];
			[self closeElementWithTag: element];
		}
		else {
			if (![element acceptsParent: [self parentElement]])
				[self closeElementWithTag: [self parentElement]];
			[self openElement: element];
		}
		[element release];
	}
	return self;//to continue parsing
}

-(void)performSelector:(SEL)method forElementsMatching:(NSString*)cssSelector{
	if (!callbackMethods){
		callbackMethods = CFArrayCreateMutable(NULL, 0, NULL);
		callbackMatchers = [[NSMutableArray alloc] initWithCapacity: 10];
	}
	CFArrayAppendValue(callbackMethods, method);
	CSSSelector* css = [[CSSSelector alloc] initWithString: cssSelector];
	CSSSelectorMatcher* matcher = [[CSSSelectorMatcher alloc] initWithSelector: css];
	[callbackMatchers addObject: matcher];
	[css release];
	[matcher release];
}

-(NSString*)description{
	NSMutableString* result = [NSMutableString string];
	Element* e = root.nextElement;
	while (e){
		[result appendString: [e description]];
		e = e.nextElement;
	}
	return result;
}

@end
