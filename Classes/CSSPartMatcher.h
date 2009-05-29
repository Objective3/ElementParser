//
//  CSSPartMatcher.h
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

#import <Foundation/Foundation.h>
#import "Element.h"
@class CSSSelectorMatcher;

/**
 *	Responsible for representing a successful match on a part.
 *	It is presented elements in an attempt to complete the next part of the match
 *
 */
@interface CSSPartMatcher : NSObject {
	CSSSelectorMatcher* selectorMatcher; // not retained
	Element* matchedElement;
	int matchedPartIndex;
	NSMutableArray* matchersForNextPart;
}
@property (nonatomic, retain) Element* matchedElement;
@property int matchedPartIndex;

-(id)initWithElement:(Element*) anElement selectorMatcher:(CSSSelectorMatcher*)aSelectorMatcher;
//-(void)pruneMatchesForElement:(Element*)anElement;
-(BOOL)matchNextElement:(Element*) nextElement forIndex: (int) index;

@end
