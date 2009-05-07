//
//  TagChunk.m
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

#import "TagChunk.h"
#import "Element.h"
#import "NSString_HTML.h"


@interface TagChunk()
@property NSStringCompareOptions compareOptions;
@end

@implementation TagChunk

@synthesize tagName, compareOptions;

-(id)initWithString: (NSString*)aSource range:(NSRange)aRange{
	assert(NO);
}

-(id)initWithString: (NSString*)aSource range:(NSRange)aRange tagName:(NSString*)aTagName{
	source = [aSource retain];
	range = aRange;
	tagName = [aTagName retain];
	compareOptions = NSCaseInsensitiveSearch;
	return self;
}

-(void)dealloc{
	[tagName release];
	[super dealloc];
}

-(NSRange)interiorRange{
	return NSMakeRange(range.location +1, range.length - 2);
}

-(NSString*)kind{
	return ChunkKindTag;
}

-(BOOL)isEmptyTag{
	return [source characterAtIndex: range.location + range.length - 2] == '/';
}

-(BOOL)isCloseTag{
	return [source characterAtIndex: range.location + 1] == '/';
}

-(BOOL)closesTag:(TagChunk*)aTag{
	NSComparisonResult result = [[self tagName] compare: [aTag tagName] 
												options: compareOptions 
												  range: NSMakeRange(1, [[self tagName] length] - 1)];
	return result == NSOrderedSame;
}

-(BOOL)tagNameEquals:(NSString*)anotherTagName{
	NSComparisonResult result = [[self tagName] compare: anotherTagName options: compareOptions];
	return result == NSOrderedSame;
}

-(BOOL)emitsNewLineInContents{
	return [self tagNameEquals: @"p"] || [self tagNameEquals: @"br"];
}


-(void)setRange: (NSRange)aRange{
	range = aRange;
}

-(BOOL)caseSensative{
	return compareOptions == NSLiteralSearch;
}

-(void)setCaseSensative:(BOOL)flag{
	compareOptions = (flag) ? NSLiteralSearch : NSCaseInsensitiveSearch;
}

-(NSString*)description{
	return [source substringWithRange: range];
}

-(NSString*)tagName{
	assert(tagName);
	return tagName;
}

+(NSString*)humanName{
	return @"tag";
}

@end
