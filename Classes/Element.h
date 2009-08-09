//
//  Element.h
//  Thumbprint
//
//  Created by Lee Buck on 4/18/09.
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
#import "TagChunk.h"

@class CSSSelector;
@class DocumentRoot;

/**
 * An Element is the fundemental building block for ElementParser.
 */
@interface Element : TagChunk {
	NSMutableDictionary* attributes;
	BOOL attributesParsed;
	Element* nextElement;
	Element* nextSybling;
	Element* parent;
	int contentsLength;
	NSString* contentsText;
	NSString* key;
	BOOL containsMarkup; // includes entities
	
	NSObject* domainObject;
}

/** 
 *	Returns a dictionary of attributes name/values. 
 *	If an attribute had no value in the source (e.g. <table noborders>) then the value will be NSNull
 *	If the attributes have not yet been parsed, this will parser them first.
 */
@property (nonatomic, readonly) NSDictionary* attributes;


/**	
 *	The character data inside the element. This text is stripped of tags, whitespace, etc
 *	by stripTags. To see the actual source within the element, use contentsSource
 */
@property (nonatomic, retain) NSString* contentsText;


/**	
 *	A case-normalized version of the tagName when appropriate. Used in situations
 *	where the tag name might need to serve as a key into a dictionary
 */
@property (nonatomic, retain) NSString* key;

/**	
 *	One or more chunks where encountered within this element
 *	Used for more efficient return of contentsText
 */
@property BOOL containsMarkup;


/**	
 *	The length of the text from the end of the start tag to the start of the end tag
 */
@property int contentsLength;


/**	
 *	The next Element encountered in the document
 */
@property (nonatomic, retain) Element* nextElement;


/**	
 *	The next sybling Element (ie the Element at the same depth with the same parent)
 */
@property (nonatomic, retain) Element* nextSybling;


/**	
 *	The parent Element to this Element
 */
@property (nonatomic, assign) Element* parent;


/**	
 *	Available for developer's use to hang an object onto this Element
 */
@property (nonatomic, retain) NSObject* domainObject;


/**	
 *	Parses the supplied source and return an Element tree with Document element serving as the root 
 *	or all top level elements. As HTML, Elements shall be considered case insensative and tag
 *	specific heuristics will be used to close tags intelligently. See ElementParser for details.
 */
+(DocumentRoot*)parseHTML:(NSString*)source;


/**	
 *	Parses the supplied source and return an Element tree with Document element serving as the root 
 *	or all top level elements. XML, Elements shall be considered case sensative. See ElementParser for details.
 */
+(DocumentRoot*)parseXML:(NSString*)source;
	
/** 
 *	Initializer used by ElementParser. See TagChunk for other intializers
 */
-(id)initWithTag:(TagChunk*)tag caseSensative:(BOOL)aCaseSensative;


/** 
 *	Returns true if the element contains the specified attribute. 
 *	If the attributes have not yet been parsed, this will parser them first.
 */
-(BOOL)hasAttribute:(NSString*)attr;


/** 
 *	Returns the value of a particular attribute (or nil if it doesn't exist)
 *	Note: ElementParser does not support default attributes
 *	If the attributes have not yet been parsed, this will parser them first.
 */
-(NSString*)attribute:(NSString*)attr;


/** 
 *	Convenience method to compare an element's tag name.
 *	Comparision will be cases sensative for XML elements and insensative for HTML elements.
 */
-(BOOL)isEqualToString:(NSString*)string;

/**
 * Convenience methods for getting NSObjects from elements and their children
 */
- (NSString*)contentsTextOfChildElement:(NSString*)selector;

- (NSNumber*)contentsNumber;

- (NSNumber*)contentsNumberOfChildElement:(NSString*)selector;


/**	
 *	An array of child Elements in document order
 */
-(NSArray*)childElements;

/**	
 *	An array of child Elements in document order
 */
-(NSArray*)syblingElements;


/** 
 *	The first child Element for this element (or nil if none).
 */
-(Element*)firstChild;


/** 
 *	A dictionary containing the tagnames of children as keys
 *	and the contentsText of the children as values.
 *	If duplicate children tag names are encountered, only the last will
 *	appear in the dictionary.
 */
-(NSDictionary*)contentsOfChildren;

/**	
 *	Returns true if the supplied Element is a parent of receiver or one of its parents
 */
-(BOOL)hasAncestor:(Element*)ancestor;


/**	
 *	Returns the nextElement but only if it has the scope Element as an ancestor
 */
-(Element*)nextElementWithinScope:(Element*)scope;


/**	
 *	Returns true if the class attribute contains the class name (perhaps as one of multiple classes).
 */
-(BOOL)hasClassName:(NSString*)aClassName;


/**	
 *	Returns true receiver can be a chlid of aParent. Used by ElementParser to prevent inappropriate
 *	nesting in HTML (e.g. <p><p>)
 */
-(BOOL)acceptsParent:(Element*)aParent;

/**	
 *	Debugging method
 */
-(NSString*)dumpTree;


/**	
 *	The source between the end of the open tag and the beginning of the close tag
 */
-(NSString*)contentsSource;


/**
 *	Convenience method for using a selector to find elements within the receiver that match.
 *	See CSSSelector for details.
 */
-(Element*)elementWithCSSSelector:(CSSSelector*)selector;

/**
 *	Convenience method for using a selector to find elements within the receiver that match
 *	See CSSSelector for details.
 */
-(Element*)selectElement:(NSString*)cssSelectorString;


/**
 *	Convenience method for using a selector to find elements within the receiver that match
 *	See CSSSelector for details.
 */
-(NSArray*)elementsWithCSSSelector:(CSSSelector*)selector;

/**
 *	Convenience method for using a selector to find elements within the receiver that match
 *	See CSSSelector for details.
 */
-(NSArray*)selectElements:(NSString*)cssSelectorString;

@end
