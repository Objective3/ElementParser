//
//  Chunk.m
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

#import "Chunk.h"


@implementation Chunk

@synthesize source, range, buffer;

-(id)initWithString: (NSString*)aSource range:(NSRange)aRange{
	source = [aSource retain];
	range = aRange;
	return self;
}

-(void)dealloc{
	[source release];
	[super dealloc];
}

-(CFRange)rangeInBuffer{
	if (buffer)
		return CFRangeMake(range.location + buffer->rangeToBuffer.location, range.length);
	else
		return CFRangeMake(kCFNotFound, 0);
}

-(CFRange)interiorRangeInBuffer{
	if (buffer){
		NSRange inRange = self.interiorRange;
		return CFRangeMake(inRange.location + buffer->rangeToBuffer.location, inRange.length);
	}
	else
		return CFRangeMake(kCFNotFound, 0);
}

-(NSRange)interiorRange{
	return range;
}

-(NSString*)interiorString{
	return [source substringWithRange: [self interiorRange]];
}

-(NSString*)kind{
	[self doesNotRecognizeSelector: _cmd];
	return nil;
}

-(BOOL)isKind:(NSString*)aKind{
	return aKind == [self kind];
}

-(NSString*)description{
	return [source substringWithRange: range];
}

+(NSString*)humanName{
	return @"generic";
}


@end
