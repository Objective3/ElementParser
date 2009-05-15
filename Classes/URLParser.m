//
//  URLParser.m
//  Thumbprint
//
//  Created by Lee Buck on 4/25/09.
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

#import "URLParser.h"
#import "NSString_HTML.h"

@implementation URLParser

@synthesize parser, connection, lastError, contentType, encoding, connectionDelegate, partialStringData;

- (id)initWithCallbackDelegate:(id)delegate{
	parser = [[ElementParser alloc] init];
	parser.delegate = delegate;
	encoding = NSISOLatin1StringEncoding;
	return self;
}	

-(void) dealloc{
	[connection cancel];
	[connection release];
	[parser release];
	[lastError release];
	[partialStringData release];
	[super dealloc];
}

-(void)parseURL:(NSURL*) url{
	NSURLRequest* request = [[NSURLRequest alloc] initWithURL: url];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];
	[parser beginParsing];
}


-(void)performSelector:(SEL)method forElementsMatching:(NSString*)cssSelector{
	[parser performSelector: method forElementsMatching: cssSelector];
}

-(void)cancelLoading{
	[connection cancel];
}


#pragma mark NSURLConnection Delegate methods

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response{
	assert(aConnection = connection);
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if ([response respondsToSelector: @selector(allHeaderFields)]){
		self.contentType = [[(NSHTTPURLResponse*)response allHeaderFields] valueForKey: @"Content-Type"];
		encoding = [NSString encodingForContentType: contentType];
		if ([contentType rangeOfString: @"html" options: NSCaseInsensitiveSearch].location != NSNotFound)
			parser.mode = ElementParserModeHTML;
		else
			parser.mode = ElementParserModeXML;
	}
	if ([connectionDelegate respondsToSelector:@selector(connection:didReceiveResponse:)])
		[connectionDelegate connection:connection didReceiveResponse: response];
	[pool release];
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
	assert(aConnection = connection);
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	self.lastError = error;
	[connection cancel];
	if ([connectionDelegate respondsToSelector:@selector(connection:didFailWithError:)])
		[connectionDelegate connection:connection didFailWithError: error];
	[pool release];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if (partialStringData){
		[partialStringData appendData: data];
		data = partialStringData;
	}
	int less;
	NSString* moreSource = nil;
	for (less = 0; less <= 3 && !moreSource; less++)
		moreSource = [[NSString alloc] initWithBytes: data.bytes length: (data.length - less) encoding: encoding];
	NSAssert(moreSource, @"unable to make string from data");
	if (--less){//decrement b/c we incremented before loop exit test
		char* charPtr = (char*) data.bytes;
		unichar c = *(charPtr + data.length - less);
		NSLog(@"Partial string received storing %i bytes, first char=%i", less, c);
		self.partialStringData = [[NSMutableData alloc] initWithBytes: charPtr + (data.length - less) length: less];
		[partialStringData release]; // setter has retained it
	}
	[parser continueParsingString: moreSource];
	[moreSource release];
	if ([connectionDelegate respondsToSelector:@selector(connection:didReceiveData:)])
		[connectionDelegate connection:connection didReceiveData: data];
	[pool release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	[parser finishParsing];
	if ([connectionDelegate respondsToSelector:@selector(connectionDidFinishLoading:)])
		[connectionDelegate connectionDidFinishLoading:connection];
	[pool release];
}


@end
