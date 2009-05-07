//
//  CSSSelectorPart.h
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

/** 
 *	CSSSelectorPart is responsible for modeling one part of CSSSelector. For example
 *	
 *		a.link[target]
 *	
 *	is a part which matches <a> tags which have a link class name and an attribute 'target'
 * 
 *  A part can consist of one or more of the following:
 *	
 *		*			All elements match (used when no tagname is supplied)
 *		tagname		Matching elements have this tag name
 *		#id			Matching elements have this as their id attribute
 *		.class		Matching elements have this as one of their class names
 *		[attr]		Matching elements have this attribute (regarless of its value)
 *		[attr=val]	Matching elements have this attribute with this value
 *
 */


@interface CSSSelectorPart : NSObject {
	NSString* identifier;
	NSString* tag;
	NSMutableArray* classNames;
	NSString* attrName;
	NSString* attrValue;
}


@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* tag;
@property (nonatomic, retain) NSArray* classNames;
@property (nonatomic, retain) NSString* attrName;
@property (nonatomic, retain) NSString* attrValue;

-(id)initWithIndex:(int*) index inString:(NSString*)string;
-(id)initWithIndex:(CFIndex*) index inBuffer:(CFStringInlineBuffer*)buffer;
-(NSString*)description;
-(BOOL)matchesElement:(Element*)element;

@end
