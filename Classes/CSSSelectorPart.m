//
//  CSSSelectorPart.m
//  Thumbprint
//
//  Created by Lee Buck on 4/17/09.
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

#import "CSSSelectorPart.h"
#import "NSString_HTML.h"

@implementation CSSSelectorPart

@synthesize identifier, tag, classNames, attrName, attrValue;

-(id)initWithIndex:(int*) index inString:(NSString*)string{
	CFStringInlineBuffer buffer;
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	CFIndex i = 0;
	self = [self initWithIndex: &i inBuffer: &buffer];
	*index = i;
	return self;
	
}

-(id)initWithIndex:(CFIndex*) index inBuffer:(CFStringInlineBuffer*)buffer{
	unichar c;
	CFIndex len;
	c = skipWhitespace(buffer, index);
	while (c > 32){
		if (c=='#'){
			len = lenToken(buffer, *index + 1);
			assert(len);
			self.identifier = createStringFromBuffer(buffer, *index + 1, len);
			[self.identifier release];//retained by property setter
			(*index) += len + 1;
		}
		else if (c == '.'){
			len = lenToken(buffer, *index + 1);
			assert(len);
			NSString* className = createStringFromBuffer(buffer, *index + 1, len);
			if (!classNames)
				classNames = [[NSMutableArray alloc] initWithObjects: className, nil];
			else
				[classNames addObject: className];
			[className release];
			(*index) += len + 1;
		}
		else if (c == '['){
			(*index)++;
			c = skipWhitespace(buffer, index);
			len = lenToken(buffer, *index);
			assert(len);
			self.attrName = createStringFromBuffer(buffer, *index, len);
			[self.attrName release];//retained by property setter
			(*index) += len;
			
			c = skipWhitespace(buffer, index);

			if (c == '='){
				(*index)++;
				c = skipWhitespace(buffer, index);
				if (c=='\''){
					len = lenThru(buffer, (*index) + 1, "'");
					assert(len);
					self.attrValue = createStringFromBuffer(buffer, *index + 1, len-1);
					(*index)++;
				}
				else if (c == '"'){
					len = lenThru(buffer, (*index) + 1, "\"");
					assert(len);
					self.attrValue = createStringFromBuffer(buffer, *index + 1, len-1);
					(*index)++;
				}
				else{
					len = lenToken(buffer, (*index));
					assert(len);
					self.attrValue = createStringFromBuffer(buffer, *index, len);
				}
				[self.attrValue release];//retained by property setter
				(*index) += len;
				c = skipWhitespace(buffer, index);
			}
			assert(c==']');				
			(*index) += 1;
		}
		else if (c == '*')
			(*index)++;
		else{
			len = lenToken(buffer, (*index));
			assert(len);
			self.tag = createStringFromBuffer(buffer, *index, len);
			[self.tag release];//retained by property setter
			(*index) += len;
		}
		c = CFStringGetCharacterFromInlineBuffer(buffer, *index);
	}
	return self;
}

-(void)dealloc{
	[identifier release];
	[tag release];
	[classNames release];
	[attrName release];
	[attrValue release];
	[super dealloc];
}

-(BOOL)matchesElement:(Element*)element{
	if(element.range.length == 0) return NO; //ElementParser's root
	if (tag && ![element tagNameEquals: tag]) return NO;
	if (identifier && ![identifier isEqualToString: [element attribute: @"id"]]) return NO;
	if (classNames){
		for (NSString* className in classNames)
			if (![element hasClassName: className]) 
				return NO;
	}
	if (attrName && attrValue && ![attrValue isEqualToString: [element attribute: attrName]]) return NO;
	if (attrName && ![element hasAttribute: attrName]) return NO;
	return YES;
}

-(NSString*)description{
	NSMutableString* result = [NSMutableString string];
	if (tag)
		[result appendString: tag];
	if (identifier)
		[result appendFormat: @"#%@", identifier];
	if (classNames){
		for (NSString* className in classNames)
			[result appendFormat: @".%@", className];
	}
	if (attrName){
		[result appendFormat: @"[%@", attrName];
		if (attrValue)
			[result appendFormat: @"='%@']", attrValue];
		else
			[result appendString: @"]"];
	}
	return result;
}

@end
