//
//  CSSSelector.h
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

#import <Foundation/Foundation.h>
#import "Element.h"

@class CSSSelectorMatcher;
@class CSSSelectorPart;

#define CSSVerbChild @" > "
#define CSSVerbSuccessor @" + "
#define CSSVerbDescendant @" "
#define CSSVerbAny @""
#define CSSVerb NSString*

/** 
 *	CSSSelector is responsible for modeling a chain of CSSSelectorParts. For example
 *	
 *		body a.link
 *	
 *	is a chain of two parts "body" and "a.link"
 * 
 *  Parts are joined by "verbs" which correspond to symbols " ", "+", and ">"
 *	These parts define the relative position of the second part to the first
 *	Supported parts are:
 *		space		within - the second part must match an Element within the 
 *					Element matching the first part
 *
 *		>			child - the second part must match an Element whose parent is  
 *					the Element matching the first part
 *
 *		+			successor - the second part must match an Element whose previous   
 *					sybling was the Element matching the first part
 */

@interface CSSSelector : NSObject {
	NSMutableArray* chain;
}
-(id)initWithString:(NSString*)string;
-(NSString*)description;

-(int)countOfParts;
-(CSSSelectorPart*)partAtIndex:(int)index;
-(CSSVerb)verbAtIndex:(int)index;
-(CSSVerb)verbAfterIndex:(int)index;
	
@end
