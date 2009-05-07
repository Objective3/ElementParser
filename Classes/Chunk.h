//
//  Chunk.h
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

#define ChunkKindDocument @"ChunkKindDocument"
#define ChunkKindTag @"ChunkKindTag"
#define ChunkKindPI @"ChunkKindPI"
#define ChunkKindComment @"ChunkKindComment"
#define ChunkKindEntity @"ChunkKindEntity"
#define ChunkKindCData @"ChunkKindCData"
#define ChunkKindDoctype @"ChunkKindDoctype"
#define ChunkKindText @"ChunkKindText"

/**
	Chunk is a range of source text that has been divided into a meaningful "chunk" by
	the NSString_HTML parser. Examples of a chunk include an element, a cdata section, an entity, 
	character data, etc. It is an abstract base class that handles basic housekeeping.
	Subclasses include TagChunk, TxtChunk, CommentChunk, EntityChunk, etc.
 */
@interface Chunk : NSObject {
	CFStringInlineBuffer* buffer;
	NSString* source;
	NSRange range;
}



/**
 A human readable name for the chunk. Used for debugging purposes.
 */
+(NSString*)humanName;


/**	
	The string that contains the whole source being parsed. 
 */
@property (nonatomic, retain) NSString* source;


/**	
	The range within the source of this chunk. Includes delimiters like '<' and '>' 
 */
@property NSRange range;


/**	During the parse (only) this buffer provides faster access to individual characters */
@property CFStringInlineBuffer* buffer;


/**	
	Only some of the whole string is buffered... when this chunk is delivered by the parser
	the whole chunk will be available in the buffer
 */
@property (readonly) CFRange rangeInBuffer;


/**
	The interior of a chunk ususally excludes the delimiters. This method does the index 
	math to point inside the buffer. Currently only used to access the character
	data within a cdata section. 
 */
@property (readonly) CFRange interiorRangeInBuffer;


/** 
	Creates a new chunk from the range aRange in aSource string
 */
-(id)initWithString: (NSString*)aSource range:(NSRange)aRange;


/**
	The interior of a chunk ususally excludes the delimiters of the chunk. 
 */
-(NSRange)interiorRange;


/**
	Convenience method that returns a string corresponding to the interior of the chunk.
 */
-(NSString*)interiorString;


/**
	Each chunk has a kind denotes what type of chunk it is.
 */
-(NSString*)kind;


/**
	Convenience method to test kind
 */
-(BOOL)isKind:(NSString*)aKind;


@end
