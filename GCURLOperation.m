//
//  GCURLOperation.m
//  QuickShot
//
//  Created by Caleb Davenport on 8/26/11.
//  Copyright 2011 GUI Cocoa, LLC. All rights reserved.
//

#import "GCURLOperation.h"

// activity count
static NSUInteger *GCURLOperationCount = 0;
static BOOL GCURLOperationShowNetworkActivityIndicator = YES;

// private interface
@interface GCURLOperation ()
+ (void)pushNetworkActivity;
+ (void)popNetworkActivity;
+ (void)updateNetworkActivityIndicatorState;
@end

// implementation
@implementation GCURLOperation

@synthesize completionBlock = __completionBlock;
@synthesize progressBlock = __progressBlock;
@synthesize outputStream = __outputStream;

#pragma mark - class methods
+ (void)runOperation:(GCURLOperation *)operation {
    static NSOperationQueue *queue = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        queue = [[NSOperationQueue alloc] init];
    });
    [queue addOperation:operation];
}
+ (void)setShouldShowNetworkActivityIndicator:(BOOL)show {
    GCURLOperationShowNetworkActivityIndicator = show;
    if (GCURLOperationShowNetworkActivityIndicator) {
        [self updateNetworkActivityIndicatorState];
    }
    else {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}
+ (void)pushNetworkActivity {
    GCURLOperationCount++;
    [self updateNetworkActivityIndicatorState];
}
+ (void)popNetworkActivity {
    if (GCURLOperationCount > 0) {
        GCURLOperationCount--;
    }
    [self updateNetworkActivityIndicatorState];
}
+ (void)updateNetworkActivityIndicatorState {
    if (GCURLOperationShowNetworkActivityIndicator) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(GCURLOperationCount > 0)];
    }
}

#pragma mark - object methods
- (id)initWithURLRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        
        // setup connection
        __connection = [[NSURLConnection alloc]
                        initWithRequest:request
                        delegate:self
                        startImmediately:NO];
        if (__connection == nil) {
            [self release];
            return nil;
        }
        
        // init primatives
        finished = NO;
        executing = NO;
        
    }
    return self;
}
- (void)dealloc {
    
    self.completionBlock = nil;
    self.progressBlock = nil;
    self.outputStream = nil;
    
    [__connection cancel];
    [__connection release];
    __connection = nil;
    
    [__data release];
    __data = nil;
    
    [__response release];
    __response = nil;
    
    [super dealloc];
    
}

#pragma mark - operation methods
- (void)start {
    
    // thread check
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:YES];
        return;
    }
    
    // if we are cancelled
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
    
    // otherwise...
    else {
        [self willChangeValueForKey:@"isExecuting"];
        executing = YES;
        [__connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [__connection start];
        [GCURLOperation pushNetworkActivity];
        [self didChangeValueForKey:@"isExecuting"];
    }
    
}
- (BOOL)isConcurrent {
    return YES;
}
- (BOOL)isFinished {
    return finished;
}
- (BOOL)isExecuting {
    return executing;
}

#pragma mark - url connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == __connection) {
        [__data release];
        __data = [[NSMutableData alloc] init];
        __response = [response copy];
    }
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == __connection) {
        NSOutputStream *stream = self.outputStream;
        GCURLOperationProgressBlock block = self.progressBlock;
        if (stream) { [stream write:[data bytes] maxLength:[data length]]; }
        else { [__data appendData:data]; }
        if (block) {
            block((CGFloat)[__data length] / (CGFloat)[__response expectedContentLength]);
        }
    }
}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    if (connection == __connection) {
        GCURLOperationProgressBlock block = self.progressBlock;
        if (block) {
            block((CGFloat)totalBytesWritten / (CGFloat)totalBytesExpectedToWrite);
        }
    }
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == __connection) {
        GCURLOperationCompletionBlock block = self.completionBlock;
        if (block) { block(__response, nil, error); }
        [GCURLOperation popNetworkActivity];
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        executing = YES;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    }
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == __connection) {
        GCURLOperationCompletionBlock block = self.completionBlock;
        if (block) { block(__response, __data, nil); }
        [GCURLOperation popNetworkActivity];
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        executing = YES;
        [self didChangeValueForKey:@"isFinished"];
        [self didChangeValueForKey:@"isExecuting"];
    }
}

@end
