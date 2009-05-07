//
//  CSSSelectorMatcher.m
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

#import "CSSSelectorMatcher.h"
#import "CSSSelectorPart.h"

@implementation CSSSelectorMatcher

@synthesize selector, matches;

-(id)initWithSelector:(CSSSelector*)aSelector{
	self = [super init];
	selector = [aSelector retain];
	rootMatch = [[CSSPartMatcher alloc] initWithElement: nil selectorMatcher: self];
	matches = [[NSMutableArray alloc] initWithCapacity: 1];
	return self;
}

-(void)dealloc{
	[selector release];
	[rootMatch release];
	[matches release];
	[super dealloc];	
}

-(Element*)firstMatch{
	return ([matches count] > 0) ? [matches objectAtIndex: 0] : nil;
}

-(BOOL)matchElement:(Element*) element{
	if ([element isCloseTag]) return NO;
	BOOL matchComplete = [rootMatch matchNextElement: element forIndex: 0];
	if (matchComplete)
		[matches addObject: element];
	return matchComplete;
}


@end
