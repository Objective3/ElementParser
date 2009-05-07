//
//  TagChunk.h
//  Thumbprint
//
//  Created by Lee Buck on 4/21/09.
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
#import "Chunk.h"


/**
	TagChunk corresponds to a tag (e.g. <body>). It may be an open, close or empty tag. It includes
	the text of the attributes.
 */

@interface TagChunk : Chunk {
	NSString* tagName;
	NSStringCompareOptions compareOptions;
}

/** 
	The name of the tag. include leading '/' for close tags 
 */
@property (nonatomic, retain) NSString* tagName;


/** 
	Determines if tagName comparisons aer case sensative (XML) or not (HTML).
 */
@property BOOL caseSensative;

/** 
	Use this initializer when the tagname has already been created as a string to reduce object allocations
 */
-(id)initWithString: (NSString*)aSource range:(NSRange)aRange tagName:(NSString*)aTagName;

/** 
	A tag that ends with '/>'
 */
-(BOOL)isEmptyTag;


/** 
	A tag that starts with '</'
 */
-(BOOL)isCloseTag;


/** 
	Is this a close tag version of aTag
 */
-(BOOL)closesTag:(TagChunk*)aTag;


/** 
	The name of the tag e.g. 'body'
 */
-(NSString*)tagName;


/** 
	Does the proper tag name comparision (ie case sensative or not)
 */
-(BOOL)tagNameEquals:(NSString*)anotherTagName;


/** 
	When reducing to plain text, is this one of the tags that should emit a new line?
	True for <br> and <p> tags.
 */
-(BOOL)emitsNewLineInContents;

@end
