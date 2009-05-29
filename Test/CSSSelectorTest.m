//
//  CSSSelectorTest.m
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

#import "CSSSelectorTest.h"


@implementation CSSSelector (Test)

+(void)assertWithCSSSelectorString:(NSString*)source expected:(NSString*)expected{
	CSSSelector* selector = [[CSSSelector alloc] initWithString: source];
	NSString* result = [selector description];
	assert([result isEqualToString: expected]);
	[selector release];
}

+(void)assertWithCSSSelectorString:(NSString*)source{
	[self assertWithCSSSelectorString: source expected: source];
}

+(void)testCSSSelector{
	//should handle tag
	[self assertWithCSSSelectorString: @"foo"];
	
	//should handle class
	[self assertWithCSSSelectorString: @".class"];
	
	//should handle multiple classes
	[self assertWithCSSSelectorString: @".class.another_class"];
	
	//should handle id
	[self assertWithCSSSelectorString: @"#identifier"];
	
	//should handle id and tag
	[self assertWithCSSSelectorString: @"foo#identifier"];
	
	//should handle class and tag
	[self assertWithCSSSelectorString: @"foo.bar"];
	
	//should handle attr
	[self assertWithCSSSelectorString: @"foo[bar]"];
	
	//should handle attr & value w/o quotes
	[self assertWithCSSSelectorString: @"foo[bar=23]" expected: @"foo[bar='23']"];
	
	//should handle attr & value w/ single quotes
	[self assertWithCSSSelectorString: @"foo[bar='23']"];
	
	//should handle whitespace in brackets & value w/ single quotes
	[self assertWithCSSSelectorString: @"foo[ bar = '23' ]" expected: @"foo[bar='23']"];
	
	//should handle attr & value w/ double quotes
	[self assertWithCSSSelectorString: @"foo[bar=\"23\"]" expected: @"foo[bar='23']"];
	
	//should handle descendant chains
	[self assertWithCSSSelectorString: @"foo bar"];
	
	//should handle successor chains
	[self assertWithCSSSelectorString: @"foo + bar"];
	
	//should handle child chains
	[self assertWithCSSSelectorString: @"foo > bar"];
	
	//should handle big and ugly
	[self assertWithCSSSelectorString: @"foo#ids > bar.huh + img[title]"];
	
}

+(void)testAll{
	[self testCSSSelector];
}
@end
