//
//  GCURLOperation.h
//  QuickShot
//
//  Created by Caleb Davenport on 8/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

// typedefs
typedef void (^GCURLOperationCompletionBlock) (NSURLResponse *response, NSData *responseBody, NSError *error);
typedef void (^GCURLOperationProgressBlock) (float progress);

/*
 Class for running URL loading operations in an asynch manner. It defines blocks
 for key events and mechanisms for getting returned information.
 */
@interface GCURLOperation : NSOperation {
@private
    NSURLConnection *__connection;
    NSURLResponse *__response;
    NSMutableData *__data;
    BOOL finished;
    BOOL executing;
}

/*
 Set this property to have returned data dumped into the stream. If this
 property is set no data will be recorded into the response body.
 */
@property (retain) NSOutputStream *outputStream;

/*
 Blocks for key events.
 */
@property (copy) GCURLOperationCompletionBlock completionBlock;
@property (copy) GCURLOperationProgressBlock progressBlock;

/*
 Create operation with the given URL request. The request object will be coppied
 so changes made to it later will have no effect.
 */
- (id)initWithURLRequest:(NSURLRequest *)request;

/*
 Run operation in a shared queue.
 */
+ (void)runOperation:(GCURLOperation *)operation;

/*
 Control whether the network activity indicator is shown for requests on the
 internal queue. This is on by default.
 */
+ (void)setShouldShowNetworkActivityIndicator:(BOOL)show;

@end
