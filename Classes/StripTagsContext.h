//
//  StripTagsContext.h
//  ElementParser
//
//  Created by Sascha Müllner on 07.10.12.
//
//

#import <Foundation/Foundation.h>

@interface StripTagsContext : NSObject

@property (nonatomic, strong) NSMutableString* result;
@property (nonatomic, assign) unichar* outBuffer;
@property (nonatomic, assign) int outBufferLength;
@property (nonatomic, assign) int writeIndex;
@property (nonatomic, assign) BOOL inScriptElement;
@property (nonatomic, assign) BOOL inWhite;
@property (nonatomic, assign) BOOL inPara;
@end
