//
//  CSSPartMatcher.m
//  Thumbprint
//
//  Created by Lee Buck on 4/19/09.
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

#import "CSSPartMatcher.h"
#import "CSSSelectorPart.h"
#import "CSSSelectorMatcher.h"

@implementation CSSPartMatcher

@synthesize matchedElement, matchedPartIndex;

-(id)initWithElement:(Element*) anElement selectorMatcher:(CSSSelectorMatcher*)aSelectorMatcher{
	self = [super init];
	matchedElement = [anElement retain];
	selectorMatcher = aSelectorMatcher;
	return self;
}

-(void)dealloc{
//	NSLog(@"pruned: %@", [self description]);
	[matchedElement release];
	[matchersForNextPart release];
	[super dealloc];
}

/* we don't do this yet...
 -(void)pruneMatchesForElement: (Element*)anElement{
	if (!matchersForNextPart) return;
	for (CSSPartMatcher* match in matchersForNextPart){
		if ([match scopeElement] == anElement)
			[matchersForNextPart removeObject: match];
		else
			[match pruneMatchesForElement: anElement];
	}
}
*/

-(void)addNextMatch:(Element*)nextElement withIndex:(int)index{
	CSSPartMatcher* nextMatch = [[CSSPartMatcher alloc] initWithElement: nextElement selectorMatcher: selectorMatcher];
	nextMatch.matchedPartIndex = index;
	if (!matchersForNextPart) 
		matchersForNextPart = [[NSMutableArray alloc] initWithCapacity: 4];
	[matchersForNextPart addObject: nextMatch];
	[nextMatch release];
}

-(BOOL)matchNextElement:(Element*) nextElement forIndex: (int) index{
	CSSSelectorPart* nextPart = [[selectorMatcher selector] partAtIndex: index];
	CSSVerb nextVerb = [[selectorMatcher selector] verbAtIndex: index];
	BOOL verbMatches = NO;
	if ([nextPart matchesElement: nextElement]){
		if (nextVerb == CSSVerbAny)
			verbMatches = YES;
		else if (nextVerb == CSSVerbDescendant)
			verbMatches = [nextElement hasAncestor: self.matchedElement];//wasteful to not prune matches as they go out of scope
		else if (nextVerb == CSSVerbChild)
			verbMatches = nextElement.parent == self.matchedElement; 
		else if (nextVerb == CSSVerbSuccessor)
			verbMatches = nextElement == self.matchedElement.nextSybling; 
	}
	
	BOOL completeMatch = verbMatches && (index == [[selectorMatcher selector] countOfParts] - 1);
	
	if (matchersForNextPart){
		for (CSSPartMatcher* match in matchersForNextPart){
			completeMatch = completeMatch || [match matchNextElement: nextElement forIndex: index + 1];
		}
	}

	if (!completeMatch && verbMatches)//actually part and verb match
		[self addNextMatch: nextElement withIndex: index];

	return completeMatch;
}

-(CSSSelectorPart*)matchedPart{
	return [[selectorMatcher selector] partAtIndex: matchedPartIndex];
}

-(NSString*)description{
	return [NSString stringWithFormat: @"%@ matched %@ -- %i matchersForNextPart", [[self matchedPart] description], [matchedElement description], (matchersForNextPart) ? [matchersForNextPart count] : 0];
}

@end
