//
//  ElementParser.h
//  Thumbprint
//
//  Created by Lee Buck on 4/20/09.
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
#import "DocumentRoot.h"

typedef enum{
	ElementParserModeHTML,
	ElementParserModeXML
} ElementParserMode;

#define ElementParserErrorDomain 1022
typedef enum{
	ElementParserTagNotClosedError = -1,
	ElementParserGeneralError = -2
}ElementParserErrors;

@interface ElementParser : NSObject {
	NSMutableArray* tagStack;
	DocumentRoot* root;
	Element* lastOpened; //assigned
	Element* lastClosedBeforeOpen;
	Chunk* lastChunk;

	CFMutableArrayRef callbackMethods;
	NSMutableArray* callbackMatchers;
	id delegate;
	ElementParserMode mode;
}

/** 
 *	The delegate that is called when selectors match
 */
@property (nonatomic, assign) id delegate;

/** 
 *	HTML or XML
 */
@property ElementParserMode mode;


/** 
 *	The source being parsed.
 */
@property (readonly) NSString* source;


/** 
 *	Parse an HMTL document and return a tree of Elements corresponding to the document.
 *	The DocumentRoot is a special Element that contains all the top-level Elements in the
 *	source.
 */
-(DocumentRoot*)parseHTML:(NSString*)source;


/** 
 *	Parse an XML document and return a tree of Elements corresponding to the document.
 *	The DocumentRoot is a special Element that contains all the top-level Elements in the
 *	source.
 */
-(DocumentRoot*)parseXML:(NSString*)source;

/** 
 *	When parsing a document incrementally, begin with a single call to beginParsing,
 *	followed by multiple calls to continueParsing as text arrives and finaly a single
 *	call to finishParsing
 */
-(DocumentRoot*)beginParsing;
-(void)continueParsingString:(NSString*)string;
-(void)finishParsing;

/** 
 *	Registers a callback to be performed whenever the supplied selector matches
 */
-(void)performSelector:(SEL)method forElementsMatching:(NSString*)cssSelector;

/** 
 *	returns true for html elements like <img>
 */
 -(BOOL)shouldBeEmptyElement:(Element*)element;

/** 
 *	internal callback when a warning condition occurs. May be overidden to surface an
 *	NSError
 */
-(void)warning:(int)code description:(NSString*)description chunk: (Chunk*)chunk;

/** 
 *	internal callback when an info condition occurs. May be overidden for debugging purposes
 */
-(void)info:(NSString*)info atIndex:(int)sourceIndex;

@end
