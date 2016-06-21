//
//  WXBaseRequest.m
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "WXBaseRequest.h"

@implementation WXBaseRequest
/// for subclasses to overwrite
- (void)requestCompleteFilter {
}

- (void)requestFailedFilter {
}

- (NSString *)requestUrl {
    return @"";
}

- (NSString *)cdnUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (WXRequestMethod)requestMethod {
    return WXRequestMethodGet;
}

- (WXRequestSerializerType)requestSerializerType {
    return WXRequestSerializerTypeHTTP;
}

- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (NSURLRequest *)buildCustomUrlRequest {
    return nil;
}

- (BOOL)useCDN {
    return NO;
}

- (id)jsonValidator {
    return nil;
}

- (BOOL)statusCodeValidator {
    NSInteger statusCode = [self responseStatusCode];
    if (statusCode >= 200 && statusCode <=299) {
        return YES;
    } else {
        return NO;
    }
}

- (AFConstructingBlock)constructingBodyBlock {
    
    return nil;
}

- (NSString *)resumableDownloadPath {
    return nil;
}

- (AFDownloadProgressBlock)resumableDownloadProgressBlock {
    return nil;
}

/// append self to request queue
- (void)start {
//    [self toggleAccessoriesWillStartCallBack];
//    [[WXNetworkAgent sharedInstance] addRequest:self];
}

/// remove self from request queue
- (void)stop {
//    [self toggleAccessoriesWillStopCallBack];
//    self.delegate = nil;
//    [[WXNetworkAgent sharedInstance] cancelRequest:self];
//    [self toggleAccessoriesDidStopCallBack];
}

//- (BOOL)isCancelled {
//    return self.requestOperation.isCancelled;
//}

//- (BOOL)isExecuting {
//    return self.requestOperation.isExecuting;
//}

- (void)startWithCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                                    failure:(WXRequestCompletionBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                              failure:(WXRequestCompletionBlock)failure {
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

//- (id)responseJSONObject {
//    return self.requestOperation.responseObject;
//}
//
//- (NSData *)responseData {
//    return self.requestOperation.responseData;
//}
//
//- (NSString *)responseString {
//    return self.requestOperation.responseString;
//}
//
//- (NSInteger)responseStatusCode {
//    return self.requestOperation.response.statusCode;
//}
//
//- (NSDictionary *)responseHeaders {
//    return self.requestOperation.response.allHeaderFields;
//}
//
//- (NSError *)requestOperationError {
//    return self.requestOperation.error;
//}

#pragma mark - Request Accessories

- (void)addAccessory:(id<WXRequestAccessory>)accessory {
    if (!self.requestAccessories) {
        self.requestAccessories = [NSMutableArray array];
    }
    [self.requestAccessories addObject:accessory];
}

@end
