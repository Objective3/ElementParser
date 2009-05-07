//
//  CSSSelectorMatcher.h
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
#import "CSSSelector.h"
#import "CSSPartMatcher.h"

/**
 *	Responsible for matching a CSSSelector.
 *	It does this by minting matching parts and creating 
 *	CSSPartMatchers for all intermediate potential matches
 *
 */

@interface CSSSelectorMatcher : NSObject {
	CSSSelector* selector;
	CSSPartMatcher* rootMatch;
	NSMutableArray* matches;
}
@property (nonatomic, retain) CSSSelector* selector;
@property (nonatomic, retain) NSMutableArray* matches;

-(id)initWithSelector:(CSSSelector*)selector;
-(BOOL)matchElement:(Element*) element;
-(Element*)firstMatch;
@end
