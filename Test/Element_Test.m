//
//  Element_Test.m
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

#import "Element_Test.h"
#import "NSString_HTML.h"
#import "DocumentRoot.h"

@implementation Element (Test)


+(void)testElement{
	NSString* result;
	Element* element;
	
	// should handle simple tagname
	result = [[@"<foo>" element] tagName];
	assert([result isEqualToString: @"foo"]);
	
	// should handle element with attributes
	element = [@"<foo att=23>" element];
	result = [element tagName];
	assert([result isEqualToString: @"foo"]);	
	assert([[element attribute: @"att"] isEqualToString: @"23"]);
	
	//should handle attributes
	element = [@"<foo att1=23 att2='red' att3 = \"what\">" element];
	assert([[element attributes] count] == 3);
	assert([[element attribute: @"att1"] isEqualToString: @"23"]);
	assert([[element attribute: @"att2"] isEqualToString: @"red"]);
	assert([[element attribute: @"att3"] isEqualToString: @"what"]);
}

+(void)testAttribute{
	NSString* result;
	
	// should handle missing attr
	result = [[@"<foo>" element] attribute: @"bar"];
	assert(result == nil);
	
	// should handle attr
	result = [[@"<foo bar=23>" element] attribute: @"bar"];
	assert([result isEqualToString: @"23"]);
	
	// should handle attr amoung others
	result = [[@"<foo red = 23 bar=23>" element] attribute: @"bar"];
	assert([result isEqualToString: @"23"]);
	
	// should handle attr with quotes
	result = [[@"<foo bar='huh' goo='4sd'>" element] attribute: @"bar"];
	assert([result isEqualToString: @"huh"]);
	
	// should handle attr without values
	result = [[@"<foo weird bar = \"goo\">" element] attribute: @"bar"];
	assert([result isEqualToString: @"goo"]);
}

+(void)testContentsOfChildren{
	Element* document = [Element parseXML: @"<feed><item><name>lee</name><phone>919-971-1377</phone></item></feed>"];
	Element* item = [document selectElement:@"item"];
	NSDictionary* kids = [item contentsOfChildren];
	assert([[kids objectForKey: @"name"] isEqualToString: @"lee"]);
	assert([[kids objectForKey: @"phone"] isEqualToString: @"919-971-1377"]);
}

+(void)testSelectElements{
	Element* root = [Element parseXML: @"<feed><item seq=1>goo</item><item seq=2>foo</item></feed>"];
	NSArray* found = [root selectElements: @"item"];
	assert([[found objectAtIndex: 0] isEqualToString: @"<item seq='1'>"]);
	assert([[found objectAtIndex: 1] isEqualToString: @"<item seq='2'>"]);
}

+(void)testSelectElement:(NSString*)source selector:(NSString*)sel expect:(NSString*)expect{
	Element* root = [Element parseHTML: source];
//	NSLog([root dumpTree]);
	Element* found = [root selectElement: sel];
	assert([[found description] isEqualToString: expect]);
}

+(void)testElementWithCSSSelector{
	
	//should handle single single part
	[self testSelectElement: @"<html><body><img src='foo'></body></html>"
				   selector: @"img"
					 expect: @"<img src='foo'>"];
	
	//should handle multiple parts
	[self testSelectElement: @"<html><body><img src='foo'></body></html>"
				   selector: @"body img"
					 expect: @"<img src='foo'>"];
	
	//should handle multiple parts with more complicated parts
	[self testSelectElement: @"<html><body><img src='foo'></body></html>"
				   selector: @"body img[src='foo']"
					 expect: @"<img src='foo'>"];
	
	//should handle a class
	[self testSelectElement: @"<html><body><a class='one'><span><img></span></a><a href='red' class='one two'><img src='foo'></a><img src='goo'></body></html>"
				   selector: @"body a.one"
					 expect: @"<a class='one'>"];
	
	//should handle a class amoung more than one
	[self testSelectElement: @"<html><body><a class='one'><span><img></span></a><a href='red' class='one two'><img src='foo'></a><img src='goo'></body></html>"
				   selector: @"body a.two"
					 expect: @"<a class='one two' href='red'>"];
	
	//should handle multiple classes amoung
	[self testSelectElement: @"<html><body><a class='one'><span><img></span></a><a href='red' class='one two'><img src='foo'></a><img src='goo'></body></html>"
				   selector: @"body a.one.two"
					 expect: @"<a class='one two' href='red'>"];
	
	//should handle multiple an id
	[self testSelectElement: @"<html><body><a class='one'><span id='bob'><img></span></a><a href='red' class='one two'><img src='foo'></a><img src='goo'></body></html>"
				   selector: @"#bob img"
					 expect: @"<img>"];
	
	//should handle multiple parts with misses
	[self testSelectElement: @"<html><body><img src='foo'><img src='goo'></body></html>"
				   selector: @"body img[src='goo']"
					 expect: @"<img src='goo'>"];
	
	//should handle successor verb
	[self testSelectElement: @"<html><body><a>here</a><span>there</span><img><a>three</a><img src='yea'></body></html>"
				   selector: @"body a + img"
					 expect: @"<img src='yea'>"];
	
	//should handle child verb
	[self testSelectElement: @"<html><body><a><span><img></span></a><a href='red'><img src='foo'></a><img src='goo'></body></html>"
				   selector: @"body a > img"
					 expect: @"<img src='foo'>"];
	
}

+(void)testSelectElemenContents:(NSString*)source selector:(NSString*)sel expect:(NSString*)expect{
	Element* root = [Element parseHTML: source];
	Element* found = [root selectElement: sel];
	assert([[found contentsSource] isEqualToString: expect]);
} 

+(void)testElementContentsWithCSSSelector{
	//should handle child verb
	[self testSelectElemenContents: @"<html><body><a href='1'>not this</a><a href='2'><span>some real text</span></a></body></html>"
						  selector: @"body a[href='2']"
							expect: @"<span>some real text</span>"];
}	
+(void)testAll{
	[self testElement];
	[self testAttribute];
	[self testContentsOfChildren];
	[self testSelectElements];
	[self testElementWithCSSSelector];
	[self testElementContentsWithCSSSelector];
	
}
@end
