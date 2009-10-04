//
//  Element.m
//  Thumbprint
//
//  Created by Lee Buck on 4/18/09.
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

#import "Element.h"
#import "NSString_HTML.h"
#import "CSSSelectorMatcher.h"
#import "ElementParser.h"

@interface Element ()
-(void)setAttributes:(NSDictionary*)dict;
@end

@implementation Element

@synthesize nextElement, nextSybling, parent, contentsLength, contentsText, key, containsMarkup, domainObject;


+(DocumentRoot*)parseHTML:(NSString*)source{
	ElementParser* parser = [[ElementParser alloc] init];
	DocumentRoot* root = [parser parseHTML: source];
	[[root retain] autorelease];
	[parser release];
	return root;
}

+(DocumentRoot*)parseXML:(NSString*)source{
	ElementParser* parser = [[ElementParser alloc] init];
	DocumentRoot* root = [parser parseXML: source];
	[[root retain] autorelease];
	[parser release];
	return root;
}

-(id)initWithString:(NSString*)string{
	return [self initWithString: string range: NSMakeRange(0, [string length])];
}

-(id)initWithTag:(TagChunk*)tag caseSensative:(BOOL)aCaseSensative{
	self = [self initWithString: tag.source range: tag.range tagName: tag.tagName];
	[self setCaseSensative: aCaseSensative];
	return self;
}

-(void)dealloc{
	[attributes release];
	[contentsText release];
	[nextElement release];
	[nextSybling release];
	[key release];
	[super dealloc];
}


-(void)setRange: (NSRange)aRange{
	attributesParsed = NO;
	[attributes removeAllObjects];
	[super setRange: aRange];
}

//cleans up nested p tags
-(BOOL)acceptsParent:(Element*)aParent{
	if ([self tagNameEquals: @"p"] && [aParent tagNameEquals: @"p"])
		return NO;
	return YES;
}


-(BOOL)closesTag:(TagChunk*)aTag{
	if (self == aTag || [self isEmptyTag]) //former case is true when shouldBeEmptyTag
		return self == aTag;
	else
		return [super closesTag: aTag];
}

-(BOOL)hasAttribute:(NSString*)attr{
	return [[[self attributes] allKeys] containsObject: attr];
}

-(NSString*)attribute:(NSString*)attr{
	return [[self attributes] objectForKey: attr];
}

// warning, may contain empty classnames
-(NSArray*)classNames{
	NSString* classNames = [self attribute: @"class"];
	if (!classNames) return [NSArray array];
	return [classNames componentsSeparatedByCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];	
}

-(BOOL)hasClassName:(NSString*)aClassName{
	if (![self attribute: @"class"]) return NO;
	for (NSString* className in [self classNames])
		if ([className isEqualToString: aClassName])
			return YES;
	return NO;
}

-(NSDictionary*)attributes{
	if (!attributesParsed){
		[self setAttributes: [source parseElementAttributesWithRange: range caseSensative: [self caseSensative]]];
		attributesParsed = YES;
	}
	return attributes;
}

-(void)setAttributes:(NSDictionary*)dict{
	[attributes release];
	attributes = [dict retain];
}

-(Element*)firstChild{
	if ([nextElement parent] == self)
		return nextElement;
	else 
		return nil;
}

-(BOOL)hasAncestor:(Element*)ancestor{
	for (Element* p = parent; p; p = p.parent){
		if (p == ancestor)
			return YES;
	}
	return NO;
}

-(Element*)nextElementWithinScope:(Element*)scope{
	if ((nextElement.parent == self) || nextSybling) 
		return nextElement;
	else
		return ([nextElement hasAncestor: scope]) ? nextElement : nil;		
}

-(NSString*)contentsText{
	if (!contentsText){
//		NSRange contentsRange = NSMakeRange(NSMaxRange(range), contentsLength);
		self.contentsText = (containsMarkup) ? [[self contentsSource] stripTags] : [self contentsSource];//[source stringByReplacingEntitiesInRange: contentsRange];
	}
	return contentsText;
}

- (NSString*)contentsTextOfChildElement:(NSString*)selector {
	return [[self selectElement:selector] contentsText];
}

- (NSNumber*)contentsNumber {
	return [NSNumber numberWithInt:[[self contentsText] intValue]];
}

- (NSNumber*)contentsNumberOfChildElement:(NSString*)selector {
	return [[self selectElement:selector] contentsNumber];
}

-(NSString*)contentsSource{
	NSRange contentsRange = NSMakeRange(NSMaxRange(range), contentsLength);
	NSString* result = [source substringWithRange: contentsRange];
	return result;
}

-(NSArray*)selectElements:(NSString*)cssSelectorString{
	if (!cssSelectorString) return [NSArray array];
	CSSSelector* selector = [[CSSSelector alloc] initWithString: cssSelectorString];
	NSArray* result = [self elementsWithCSSSelector: selector];
	[selector release];
	return result;
}

-(Element*)selectElement:(NSString*)cssSelectorString{
	if (!cssSelectorString) return nil;
	CSSSelector* selector = [[CSSSelector alloc] initWithString: cssSelectorString];
	Element* result = [self elementWithCSSSelector: selector];
	[selector release];
	return result;
}

-(NSArray*)elementsWithCSSSelector:(CSSSelector*)selector{
	CSSSelectorMatcher* matcher = [[CSSSelectorMatcher alloc] initWithSelector: selector];
	Element* e = self;
	while (e){
		[matcher matchElement: e];
		// e = e.nextElement;
		e = [e nextElementWithinScope: self];
	}
	NSArray* result = [[[matcher matches] retain] autorelease];
	[matcher release];
	return result;
}

-(Element*)elementWithCSSSelector:(CSSSelector*)selector{
	CSSSelectorMatcher* matcher = [[CSSSelectorMatcher alloc] initWithSelector: selector];
	Element* e = self;
	BOOL success = NO;
	while (e && !success){
		success = [matcher matchElement: e];
		e = [e nextElementWithinScope: self];
	}
	Element* result = [matcher firstMatch];
	[matcher release];
	return result;
}

-(NSArray*)childElements{
	NSMutableArray* kids = [NSMutableArray array];
	Element* e = [self firstChild];
	while (e){
		[kids addObject: e];
		e = e.nextSybling;
	}
	return kids;
}

-(NSArray*)syblingElements{
	NSMutableArray* syblings = [NSMutableArray array];
	Element* e = self;
	while (e){
		[syblings addObject: e];
		e = e.nextSybling;
	}
	return syblings;
}

-(NSDictionary*)contentsOfChildren{
	NSMutableDictionary* result = [NSMutableDictionary dictionary];
	Element* e = [self firstChild];
	while (e){
		[result setObject: [e contentsText] forKey: [e key]];
		e = e.nextSybling;
	}
	return result;
}

-(BOOL)isEqualToString:(NSString*)string{
	return [[self description] isEqualToString: string];
}

-(NSString*)key{
	if (!key)
		self.key = ([self caseSensative]) 
			? [self tagName] 
			: [[self tagName] lowercaseString];
	return key;
}	

-(NSString*)description{
	NSMutableString* result = [NSMutableString string];
	if (!source) return result;//root element has no source
	[result appendString: @"<"];
	[result appendString: [self tagName]];
	for (NSString* att in [[self attributes] allKeys]){
		[result appendFormat: @" %@='%@'", att, [attributes objectForKey: att]];
	}
	if ([self isEmptyTag])
		[result appendString: @" />"];
	else		
		[result appendString: @">"];
	return result;	
}

-(NSString*)dumpTree{
	NSMutableString* result = [NSMutableString string];
	Element* e = self;
	while (e){
		for (Element* ee = e; ee; ee = [ee parent])
			[result appendString: @"   "];			
		[result appendString: [e description]];
		NSString* txt = (e.containsMarkup) ? @"..." : e.contentsText;
		[result appendFormat: @"%@\n", txt];
		e = e.nextElement;
	}
	return result;
}

@end
