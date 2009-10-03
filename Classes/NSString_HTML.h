//
//  NSString_HTML.h
//  Thumbprint
//
//  Created by Lee Buck on 3/27/09.
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
#import "CSSSelector.h"
@class Element;

/**
 *	spins through string buffer until character a or b encountered (or end of buffer)
 */
CFIndex lenThruOr(CFStringInlineBuffer* buffer, CFIndex index, const char a, const char b);

/**
  * spins though an attribute/value pair inside an element
 */

CFIndex lenAttributeAndValue(CFStringInlineBuffer* buffer, CFIndex index, NSString** attrName, NSString**attrValue);

/**
 *	spins through string buffer until a white character is encountered.
 *	Assumes <32 denotes whitespace. Returns 0 if end of buffer encountered.
 */
unichar skipNonWhitespace(CFStringInlineBuffer* buffer, CFIndex* index);


/**
 *	spins through string buffer until a non white character is encountered.
 *	Assumes <32 denotes whitespace. Returns 0 if end of buffer encountered.
 */
unichar skipWhitespace(CFStringInlineBuffer* buffer, CFIndex* index);


/**
 *	spins through string buffer until a non token character is encountered.
 *	Returns length of the token. Used for attributes, class names, identifiers and tag names.
 *	Does not accommodate non latin characters.
 *	Accepts '-', '_', ':' even when in first character position
 *	Also permits '/' to begin the token (simplifies parsing close tags). 
 */
CFIndex lenToken(CFStringInlineBuffer* buffer, CFIndex index);


/**
 *	Returns true if the characters in th buffer at index begin with the supplied string
 */
CFIndex startsWithStr(CFStringInlineBuffer* buffer, CFIndex index, const char* prefix);

/**
 *	Parses an entity name and returns its length. Returns 0 if end of buffer
 * is encountered or NSNotFound of an invalid entity is encountered.
 */
CFIndex lenEntityName(CFStringInlineBuffer* buffer, CFIndex index);


/**
 *	Spins through buffer until the supplied suffix is encountered. Returns
 *	0 if end of buffer is encountered before the suffix.
 */
CFIndex lenThru(CFStringInlineBuffer* buffer, CFIndex index, const char* suffix);

/**
 *	Spins through buffer until the supplied suffix is encountered. Does not
 *  match on characters with single or double quotes.
 *	Returns 0 if end of buffer is encountered before the suffix.
 */
CFIndex lenThruRespectingQuotes(CFStringInlineBuffer* buffer, CFIndex index, const char* suffix);

/**
 *	Returns the character corresponding to the entity at the supplied index in the buffer
 */
unichar parseEntity(CFStringInlineBuffer* buffer, CFIndex index, CFIndex* len);


/**
 *	Parses the doctype at the suppied index in the buffer and returns its length.
 *	Return 0 if end of buffer encountered first
 */
CFIndex lenDoctype(CFStringInlineBuffer* buffer, CFIndex index);


/**
 *	Convenience method that creates an string from a range in the buffer
 */
NSString* createStringFromBuffer(CFStringInlineBuffer* buffer, CFIndex index, CFIndex length);
											
@interface NSString (HTML)

/**
 *	converts the string assuming it is a hex number 
 */
-(int)hexValue;


/**
 *	Returns a string in which 
 *		a) all the tags have been removed
 *		b) entities are resolved
 *		c) cdata sections are processed
 *		d) whitespace is compressed
 *		e) html markup like <br> and <p> are used to provide minimal formatting
 */
-(NSString*)stripTags;


/**
 *	Convenience method to url encode a string
 */
-(NSString*)stringByAddingPercentEscaping;


/**
 *	Convenience method to url decode a string
 */
-(NSString*)stringByRemovingPercentEscaping;


/**
 *	Resolves entities in string
 */
-(NSString*)stringByReplacingEntities;


/**
 *	Convenienece method that replaces entities for a range
 */
-(NSString*)stringByReplacingEntitiesInRange:(NSRange)range;


/**
 *	Convenienece method to create an element
 */
-(Element*)element;


/**
 *	Parses an element returning its attributes. 
 */
-(NSDictionary*)parseElementAttributesWithRange:(NSRange) range caseSensative:(BOOL)caseSensative;


/**
 *	Very simpleminded parsing out of character encoding based on an http header contentType
 */
+ (NSStringEncoding) encodingForContentType:(NSString *)contentType;


/**
 *	The base parser that spins through a string and calls a delegate for each chunk encountered.
 *	Chucks include: tags, entities, comments, cdata, characters and others.
 *	ElementParser uses this low level parser to build an Element tree.
 */
+(void)parseHTML:(NSString*) source delegate:(id)delegate selector:(SEL)selector context: (void*) context;

/**
 *	The base parser that spins through a string and calls a delegate for each chunk encountered.
 *	This version of the method permits partial parsing... ie the parser will stop if
 *	it encounters a chunk that extends beyond the end of the string. It can be called
 *	repeatedly as more text arrives and is appended to the string.
 */
+(void)parseHTML:(NSString*)source delegate:(id)delegate selector:(SEL)selector context: (void*) context index:(int*)sourceIndex partial:(BOOL)partial;
	
@end
