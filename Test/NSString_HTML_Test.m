//
//  NSString_HTML_Test.m
//  Thumbprint
//
//  Created by Lee Buck on 4/16/09.
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

#import "NSString_HTML_Test.h"
#import "NSString_HTML.h"
#import "NSString_Additions.h"
#import "Element.h"
#import "Chunk.h"
#import "ElementParser.h"


@implementation NSString (HTML_Test)

+(void)testStripTags{
	NSString* result;
	// should strip tags
	result = [@"<foo>this is some text</foo>" stripTags];
	assert([result isEqualToString: @"this is some text"]);
	
	//should handle text outside of tags
	result = [@"outside some stuff <foo>this is some text</foo>" stripTags];
	assert([result isEqualToString: @"outside some stuff this is some text"]);
	
	//should handle entities
	result = [@"<foo>this is some text &amp; and more</foo>" stripTags];	
	assert([result isEqualToString: @"this is some text & and more"]);
	
	//should handle bad entities
	result = [@"<foo>this is some text &amp and more</foo>" stripTags];	
	assert([result isEqualToString: @"this is some text &amp and more"]);
	
	// should replace p tags with returns (and BRs)
	result = [@"<foo>this is <p>some text </p>and more</foo>" stripTags];	
	assert([result isEqualToString: @"this is \n\nsome text and more"]);
		
	//should handle not including script tags
	result = [@"<foo>this is <p>some text <script>but not here</script>and more</foo>" stripTags];	
	assert([result isEqualToString: @"this is \n\nsome text and more"]);

	//should handle illformed html... (and BRs)
	result = [@"<foo>this is <p>some text <br>and more</foo>" stripTags];	
	assert([result isEqualToString: @"this is \n\nsome text \n\nand more"]);
}



+(id)chunk:(Chunk*)chunk context:(NSMutableString*)result{
	[result appendString: [chunk interiorString]];
	[result appendString: @"|"];
	return self;//continue
}

+(void)testParseHTML{
	NSMutableString* result = [@"|" mutableCopy];
	NSString* source = @"<foo>some <!--ignoreme-->text &quot;goes here</foo><b class='huh'><c /></b>";
	[NSString parseHTML: source delegate: self selector: @selector(chunk:context:) context: result];
	assert([result isEqualToString: @"|foo|some |ignoreme|text |quot|goes here|/foo|b class='huh'|c /|/b|"]);
}

+(void)testStringByReplacingEntities{
	NSString* result;
	
	//should handle no entities
	result = [@"foo" stringByReplacingEntities];
	assert([result isEqualToString: @"foo"]);

	//should handle entity at start
	result = [@"&gt;foo" stringByReplacingEntities];
	assert([result isEqualToString: @">foo"]);

	//should handle entity at end
	result = [@"foo&lt;" stringByReplacingEntities];
	assert([result isEqualToString: @"foo<"]);

	//should handle unknown entity
	result = [@"foo&dddlt;" stringByReplacingEntities];
	assert([result isEqualToString: @"foo&dddlt;"]);

	//should handle badly formed entity
	result = [@"foo&dddlt" stringByReplacingEntities];
	assert([result isEqualToString: @"foo&dddlt"]);
}



+(void)testStartsWithStr{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	
	//should match or not
	assert(startsWithStr(&buffer, 1, "oo"));
	assert(!startsWithStr(&buffer, 0, "oo"));
	assert(!startsWithStr(&buffer, 5, "oo"));
}

+(void)testLenEntityName{
	NSString* string = @"#foo;&#ng";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	
	//should match or not
	assert(lenEntityName(&buffer, 0)==5);
	assert(lenEntityName(&buffer, 5)==0);
}

+(void)testLenThruOr{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	
	//lenThruOr
	assert(lenThruOr(&buffer, 0, 'o', '2')==1);
	assert(lenThruOr(&buffer, 0, '2', '1')==4);
	assert(lenThruOr(&buffer, 0, 'w', '2')==4);
	assert(lenThruOr(&buffer, 0, 'x', 'z')==9);
	assert(lenThruOr(&buffer, 3, 'o', '2')==1);
}

+(void)testLenThru{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	
	assert(lenThru(&buffer, 2, "23")==4);
	assert(lenThru(&buffer, 0, "23")==6);
	assert(lenThru(&buffer, 0, "oa")==9);
	assert(lenThru(&buffer, 0, "XXX")==0);
	
}

+(void)testSkipNonWhitespace{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);

	CFIndex index = 0;
	// skips non white
	assert(skipNonWhitespace(&buffer, &index)==' ');
	assert(index == 3);
	
	//don't skip if already nonwhite
	assert(skipNonWhitespace(&buffer, &index)==' ');
	assert(index == 3);
	
	//return 0 if hit end of string before white char
	index = 7;
	assert(skipNonWhitespace(&buffer, &index)==0);
	assert(index == 9);
}

+(void)testSkipWhitespace{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);

	CFIndex index;
	
	//skip a white
	index = 3;
	assert(skipWhitespace(&buffer, &index)=='2');
	assert(index == 4);
	
	// don't skip if already non white
	assert(skipWhitespace(&buffer, &index)=='2');
	assert(index == 4);
	
}

+(void)testLenToken{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);

	assert(lenToken(&buffer, 0)==3);
	//	should return 0 if not in a token
	assert(lenToken(&buffer, 3)==0);
	
}
+(void)testParseEntity{
	NSString* string = @"foo 23 oa";
	CFStringInlineBuffer buffer;
	
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);

	CFIndex len;
	
	string = @"&amp;";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(parseEntity(&buffer, 0, &len)=='&');
	
	string = @"&apos;";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(parseEntity(&buffer, 0, &len)=='\'');
	
	string = @"&#x20;";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	char c = parseEntity(&buffer, 0, &len); 
	assert(c==' ');
	
	string = @"&#32;";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(parseEntity(&buffer, 0, &len)==' ');
	
	string = @"&foo;";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(parseEntity(&buffer, 0, &len)==0);
	
	string = @"&mdas";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(parseEntity(&buffer, 0, &len)==0);
	
}

+(void)testLenDoctype{
	NSString* string = @"<!DOCTYPE html>";	
	CFStringInlineBuffer buffer;
	CFRange range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(lenDoctype(&buffer, 0)==[string length]);
	
	string = @"<!DOCTYPE html[\n] >";	
	range = CFRangeMake(0, [string length]);
	CFStringInitInlineBuffer((CFStringRef)string, &buffer, range);
	assert(lenDoctype(&buffer, 0)==[string length]);
	
}

+(void)testHexValue{
	// should handle vanilla input
	assert([@"12" hexValue] == 18);
	// should handle upper case digits
	assert([@"1A" hexValue] == 26);
	// should handle lower case digits
	assert([@"1c" hexValue] == 28);
	// should handle bad characters by stopping
	assert([@"10g34" hexValue] == 16);
	// should handle empty string by returning 0
	assert([@"" hexValue] == 0);
	// should handle bad strings by returning 0
	assert([@"wywt" hexValue] == 0);
}


+(void)testAllHTMLTest{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[NSString testStartsWithStr];
	[NSString testLenEntityName];
	[NSString testLenThruOr];
	[NSString testLenThru];
	[NSString testSkipNonWhitespace];
	[NSString testSkipWhitespace];
	[NSString testLenToken];
	[NSString testParseEntity];
	[NSString testLenDoctype];
	[NSString testStripTags];
	[NSString testParseHTML];
	[NSString testStringByReplacingEntities];
	[NSString testHexValue];
	[pool release];
}
@end

