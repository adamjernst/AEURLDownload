//
//  AEURLDownload.h
//  TransitMaps
//
//  Created by Adam Ernst on 3/6/12.
//  Copyright (c) 2012 cosmicsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^AEURLDownloadCompletionHandler)(NSURLResponse *, NSURL *, NSError *);

extern NSString *AEURLDownloadErrorDomain;

enum {
    AEURLDownloadErrorTemporaryFileFailed = -100,
};

@interface AEURLDownload : NSObject

+ (AEURLDownload *)downloadWithRequest:(NSURLRequest *)request
                     completionHandler:(AEURLDownloadCompletionHandler)handler;

+ (AEURLDownload *)downloadWithRequest:(NSURLRequest *)request
                           runLoopMode:(NSString *)runLoopMode // on [NSRunLoop mainRunLoop]
                     completionHandler:(AEURLDownloadCompletionHandler)handler;

// Cancel an in-progress download. No-op if already finished or canceled.
// completionHandler will not be called if the download was in progress.
- (void)cancel;

@end
