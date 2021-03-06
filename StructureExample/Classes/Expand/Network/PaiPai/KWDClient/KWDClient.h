//
//  KWDClient.h
//  WXD
//
//  Created by Fantasy on 11/11/14.
//  Copyright (c) 2014 JD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPRequest.h"


@interface KWDClient : NSObject
@property (nonatomic, copy) NSDictionary *commonParameters;
@property (readonly, nonatomic, copy) NSString *wdBaseURL;

+ (instancetype)shareInstance;

- (NSURLSessionDataTask *)startRequest:(HTTPRequest *)request;

- (void)addRequest:(HTTPRequest *)request;

- (void)cancelRequest:(HTTPRequest *)request;

- (void)cancelAllRequests;
@end
