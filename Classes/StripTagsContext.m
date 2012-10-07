//
//  StripTagsContext.m
//  ElementParser
//
//  Created by Sascha Müllner on 07.10.12.
//
//

#import "StripTagsContext.h"

@implementation StripTagsContext
@synthesize result = _result;
@synthesize outBuffer = _outBuffer;
@synthesize outBufferLength = _outBufferLength;
@synthesize writeIndex = _writeIndex;
@synthesize inScriptElement = _inScriptElement;
@synthesize inWhite = _inWhite;
@synthesize inPara = _inPara;
@end
