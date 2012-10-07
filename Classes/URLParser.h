//
//  URLParser.h
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

#import <Foundation/Foundation.h>
#import "ElementParser.h"


@interface URLParser : NSObject {
	NSError* lastError;
	NSURLConnection* connection;
	ElementParser* parser;
	NSString* contentType;
	NSStringEncoding encoding;
	id __weak connectionDelegate;
	NSMutableData* partialStringData;
}

@property(weak, nonatomic) id connectionDelegate;
@property(strong, readonly) NSURLConnection* connection;
@property(strong, readonly) ElementParser* parser;
@property(strong, nonatomic) NSError* lastError;
@property(strong, nonatomic) NSString* contentType;
@property NSStringEncoding encoding;
@property (strong, nonatomic) NSMutableData* partialStringData;


-(id)initWithCallbackDelegate:(id)delegate;
-(void)performSelector:(SEL)method forElementsMatching:(NSString*)cssSelector;
-(void)parseURL:(NSURL*) url;
-(void)cancelLoading;

@end

@protocol URLParser
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection;
@end