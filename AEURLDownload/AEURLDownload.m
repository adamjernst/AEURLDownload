//
//  AEURLDownload.m
//  TransitMaps
//
//  Created by Adam Ernst on 3/6/12.
//  Copyright (c) 2012 cosmicsoft. All rights reserved.
//

#import "AEURLDownload.h"

NSString *AEURLDownloadErrorDomain = @"AEURLDownloadErrorDomain";

@interface AEURLDownload () {
    AEURLDownloadCompletionHandler _handler;
    NSFileHandle *_writeHandle;
    NSURL *_downloadURL;
}
- (id)initWithCompletionHandler:(AEURLDownloadCompletionHandler)handler;

@property (nonatomic, retain) NSURLResponse *response;
@property (nonatomic, assign) NSURLConnection *connection;
@end

@implementation AEURLDownload

@synthesize response=_response;
@synthesize connection=_connection;

+ (AEURLDownload *)downloadWithRequest:(NSURLRequest *)request
                     completionHandler:(AEURLDownloadCompletionHandler)handler {
    return [AEURLDownload downloadWithRequest:request
                                  runLoopMode:NSDefaultRunLoopMode
                            completionHandler:handler];
}

+ (AEURLDownload *)downloadWithRequest:(NSURLRequest *)request
                           runLoopMode:(NSString *)runLoopMode
                     completionHandler:(AEURLDownloadCompletionHandler)handler {
    AEURLDownload *download = [[[AEURLDownload alloc] initWithCompletionHandler:handler] autorelease];
    NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:download startImmediately:NO] autorelease];
    [download setConnection:connection]; // non-retaining reference
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:runLoopMode];
    [connection start];
    return download;
}

- (id)initWithCompletionHandler:(AEURLDownloadCompletionHandler)handler {
    self = [super init];
    if (self) {
        _handler = [handler copy];
        
        char *temp_template = strdup([[NSTemporaryDirectory() stringByAppendingPathComponent:@"aeurldownload.XXXXXX"] fileSystemRepresentation]);
        int download_fd = mkstemp(temp_template);
        if (download_fd == -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(nil, nil, [NSError errorWithDomain:AEURLDownloadErrorDomain code:AEURLDownloadErrorTemporaryFileFailed userInfo:nil]); // TODO
            });
            [self release];
            free(temp_template);
            return nil;
        }
        
        _writeHandle = [[NSFileHandle alloc] initWithFileDescriptor:download_fd closeOnDealloc:YES];
        _downloadURL = [[NSURL fileURLWithPath:[[[[NSFileManager alloc] init] autorelease] stringWithFileSystemRepresentation:temp_template length:strlen(temp_template)]] retain];
        free(temp_template);
    }
    return self;
}

- (void)dealloc {
    [_handler release];
    [_writeHandle release];
    // [NSFileManager defaultManager] is not thread-safe; to be safe make our own manager
    [[[[NSFileManager alloc] init] autorelease] removeItemAtURL:_downloadURL error:NULL];
    [_downloadURL release];
    [_response release];
    [super dealloc];
}

- (void)cancel {
    [[self connection] cancel];
    [self setConnection:nil];
}

#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self setResponse:response];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_writeHandle writeData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self setConnection:nil];
    [_writeHandle synchronizeFile];
    _handler([self response], _downloadURL, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self setConnection:nil];
    _handler(nil, nil, error);
}

@end
