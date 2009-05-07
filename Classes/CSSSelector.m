//
//  CSSSelector.m
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

#import "CSSSelector.h"
#import "CSSSelectorPart.h"
#import "NSString_HTML.h"
#import "CSSSelectorMatcher.h"


@implementation CSSSelector


-(id)initWithString:(NSString*)string{
	CFStringInlineBuffer buffer;
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	
	chain = [[NSMutableArray alloc] initWithCapacity: 10];
	unichar c;
	CFIndex index = 0;
	while (c = skipWhitespace(&buffer, &index)){
		CSSSelectorPart* part = [[CSSSelectorPart alloc] initWithIndex: &index inBuffer: &buffer];
		[chain addObject: part];
		[part release];
		
		c = skipWhitespace(&buffer, &index);
		if (!c) break;
		
		if (c=='+'){
			[chain addObject: CSSVerbSuccessor];
			index++;
		}
		else if (c=='>'){
			[chain addObject: CSSVerbChild];
			index++;
		}
		else
			[chain addObject: CSSVerbDescendant];
	}

	return self;
}

-(void)dealloc{
//	NSLog(@"disposing of %@", [self description]);
	[chain release];
	[super dealloc];
}

-(NSString*)description{
	NSMutableString* result = [NSMutableString string];
	for (id item in chain){
		[result appendString: [item description]];
	}
	return result;	
}
 
-(int)countOfParts{
	return ([chain count] + 1) / 2;
}
-(CSSSelectorPart*)partAtIndex:(int)index{
	return [chain objectAtIndex: index * 2];
}

-(CSSVerb)verbAtIndex:(int)index{
	return (index > 0) ? [chain objectAtIndex: index * 2 - 1] : CSSVerbAny;
}

// sometime we need to access the next verb after an index... see scopingElement
-(CSSVerb)verbAfterIndex:(int)index{
	return (index < [self countOfParts] - 1) ? [self verbAtIndex: index + 1] : CSSVerbAny;
}

@end


