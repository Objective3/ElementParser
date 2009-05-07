//
//  ElementParserTest.m
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

#import "ElementParserTest.h"
#import "NSString_HTML.h"

@implementation ElementParser (Test)

+(void)testElementParser{
	ElementParser* builder = [[ElementParser alloc] init];
	NSString* source = @"<html><body><a>some test</a><p>more text</p></body></html>";
	NSString* expect = @"<html><body><a><p>";
	Element* root = [builder parseHTML: source];
	NSString* result = [builder description];
	assert([result isEqualToString: expect]);
	
	Element* body = [root selectElement: @"body"];
	assert([[body description] isEqualToString: @"<body>"]);
	assert([[body contentsSource] isEqualToString: @"<a>some test</a><p>more text</p>"]);
}

+(void)testShouldBeEmpty{
	ElementParser* builder = [[ElementParser alloc] init];
	assert([builder shouldBeEmptyElement: [@"<br>" element]]);
	assert([builder shouldBeEmptyElement: [@"<IMG>" element]]);
	assert(![builder shouldBeEmptyElement: [@"<p>" element]]);
	assert(![builder shouldBeEmptyElement: [@"<DIV>" element]]);
}

+(void)testFeedPerf{
	NSString* file = [[NSBundle mainBundle] pathForResource: @"gizmodo" ofType: @"xml"];
	NSString* source = [NSString stringWithContentsOfFile: file];
	assert(source);
	
	int runs = 10;
	
	NSTimeInterval start;
	start = [NSDate timeIntervalSinceReferenceDate];
	for (int i = 0; i < runs; i++){
		Element* root = [Element parseXML: source];
		NSArray* items = [root selectElements: @"item"];
		for (Element* item in items){
			[[item selectElement: @"title"] contentsText];
			NSString* description = [[item selectElement: @"description"] contentsText];
			
			Element* descriptionDocument = [Element parseHTML: description];
			[descriptionDocument contentsText];
			[[descriptionDocument selectElement: @"img"] attribute: @"src"];
		}
	}
	
	NSLog(@"%i runs processing feed: %f", runs, [NSDate timeIntervalSinceReferenceDate] - start);	
}

+(void)testFeed{
	NSString* file = [[NSBundle mainBundle] pathForResource: @"gizmodo" ofType: @"xml"];
	NSString* source = [NSString stringWithContentsOfFile: file];
	assert(source);

	Element* root = [Element parseXML: source];
	NSArray* items = [root selectElements: @"item"];
	for (Element* item in items){
		NSString* title = [[item selectElement: @"title"] contentsText];
		NSString* description = [[item selectElement: @"description"] contentsText];
		
		Element* descriptionDocument = [Element parseHTML: description];
		NSString* strippedDescr = [descriptionDocument contentsText];
		NSString* descrImg = [[descriptionDocument selectElement: @"img"] attribute: @"src"];
		
		NSLog(@"\n\n%@\n%i chars in descr beginning with: %@\nStripped:%@\nImage: %@", title, [description length], [description substringToIndex: MIN([description length], 32)], [strippedDescr substringToIndex: MIN([strippedDescr length], 32)], descrImg);
	}

	assert([items count] == 40);		
}

+(void)testAll{
	[self testFeedPerf];
	[self testFeed];
	[self testElementParser];
	[self testShouldBeEmpty];
}


@end
