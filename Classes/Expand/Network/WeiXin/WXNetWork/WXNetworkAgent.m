//
//  WXKNetworkAgent.m
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "WXNetworkAgent.h"
#import "MacrosPublicHeader.h"
#import "WXNetworkPrivate.h"
#import "AFURLResponseSerialization.h"

@interface WXNetworkAgent (){
    AFHTTPSessionManager *_manager;
//    WXNetworkConfig *_config;
    NSMutableDictionary *_requestsRecordDictionaryM;
    //Request 请求队列
    dispatch_queue_t _requestProcessingQueue;
}
@end

@implementation WXNetworkAgent

+ (WXNetworkAgent *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
//        _config = [WXNetworkConfig sharedInstance];
        _manager = [AFHTTPSessionManager manager];
        //设定安全策略
        _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        _requestsRecordDictionaryM = [NSMutableDictionary dictionary];
        //最大的请求数
        _manager.operationQueue.maxConcurrentOperationCount = 4;
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}
//判断URL 地址的正确性
- (NSString *)buildRequestUrl:(WXBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    if ([detailUrl hasPrefix:@"https"]) {
        return detailUrl;
    }
    // filter url
//    NSArray *filters = [_config urlFilters];
//    for (id<WXUrlFilterProtocol> f in filters) {
//        detailUrl = [f filterUrl:detailUrl withRequest:request];
//    }
    
    NSString *baseUrl = @"";
//    if ([request useCDN]) {
//        if ([request cdnUrl].length > 0) {
//            baseUrl = [request cdnUrl];
//        } else {
//            baseUrl = [_config cdnUrl];
//        }
//    } else {
//        if ([request baseUrl].length > 0) {
//            baseUrl = [request baseUrl];
//        } else {
//            baseUrl = [_config baseUrl];
//        }
//    }
    return [NSString stringWithFormat:@"%@%@", baseUrl, detailUrl];
}

- (void)addRequest:(WXBaseRequest *)request {
    WXRequestMethod method = [request requestMethod];
    NSString *url = [self buildRequestUrl:request];
    id param = request.requestArgument;
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == WXRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == WXRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    
    // if api need server username and password
    NSArray *authorizationHeaderFieldArray = [request requestAuthorizationHeaderFieldArray];
    if (authorizationHeaderFieldArray != nil) {
        [requestSerializer setAuthorizationHeaderFieldWithUsername:(NSString *)authorizationHeaderFieldArray.firstObject
                                                          password:(NSString *)authorizationHeaderFieldArray.lastObject];
    }
    
    // if api need add custom value to HTTPHeaderField
    NSDictionary *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (id httpHeaderField in headerFieldValueDictionary.allKeys) {
            id value = headerFieldValueDictionary[httpHeaderField];
            if ([httpHeaderField isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
                [requestSerializer setValue:(NSString *)value forHTTPHeaderField:(NSString *)httpHeaderField];
            } else {
                DLog(@"Error, class of key/value in headerFieldValueDictionary should be NSString.");
            }
        }
    }
    
    // if api build custom url request
    NSURLRequest *customUrlRequest= [request buildCustomUrlRequest];
    if (customUrlRequest) {
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:customUrlRequest.URL];
        NSURLSessionDataTask *sessionDataTask = [manager POST:@"" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
            //请求的 uploadProgress
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [self handleRequestResult:task];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [self handleRequestResult:task];
        }];
        request.sessionDataTask = sessionDataTask;
        manager.responseSerializer = _manager.responseSerializer;
        
    } else {
        if (method == WXRequestMethodGet) {
//            if (request.resumableDownloadPath) {
//                // add parameters to URL;
//                NSString *filteredUrl = [WXNetworkPrivate urlStringWithOriginUrlString:url appendParameters:param];
//                
//                NSURLRequest *requestUrl = [NSURLRequest requestWithURL:[NSURL URLWithString:filteredUrl]];
//                AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:requestUrl
//                                                                                                 targetPath:request.resumableDownloadPath shouldResume:YES];
//                [operation setProgressiveDownloadProgressBlock:request.resumableDownloadProgressBlock];
//                [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                    [self handleRequestResult:operation];
//                }                                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                    [self handleRequestResult:operation];
//                }];
//                request.requestOperation = operation;
//                [_manager.operationQueue addOperation:operation];
//            } else {
//                request.requestOperation = [self requestOperationWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param];
//            }
        } else if (method == WXRequestMethodPost) {
//            if (constructingBlock != nil) {
//                NSError *serializationError = nil;
//                NSMutableURLRequest *urlRequest = [requestSerializer multipartFormRequestWithMethod:@"POST" URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:&serializationError];
//                if (serializationError) {
//                    dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
//                        [self handleRequestResult:nil];
//                    });
//                } else {
//                    AFHTTPRequestOperation *operation = [self requestOperationWithRequest:urlRequest success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        [self handleRequestResult:operation];
//                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        [self handleRequestResult:operation];
//                    }];
//                    request.requestOperation = operation;
//                    [_manager.operationQueue addOperation:operation];
//                }
//            } else {
//                request.requestOperation = [self requestOperationWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param];
//            }
        } else if (method == WXRequestMethodHead) {
        } else if (method == WXRequestMethodPut) {
        } else if (method == WXRequestMethodDelete) {
        } else if (method == WXRequestMethodPatch) {
        } else {
            return;
        }
    }
    
    // Set request operation priority
    switch (request.requestPriority) {
        case WXRequestPriorityHigh:
            request.sessionDataTask.priority = NSOperationQueuePriorityHigh;
            break;
        case WXRequestPriorityLow:
            request.sessionDataTask.priority = NSOperationQueuePriorityLow;
            break;
        case WXRequestPriorityDefault:
        default:
            request.sessionDataTask.priority = NSOperationQueuePriorityNormal;
            break;
    }
    
    // retain operation
    DLog(@"Add request: %@", NSStringFromClass([request class]));
    [self addOperation:request];
}

- (void)cancelRequest:(WXBaseRequest *)request {
    [request.sessionDataTask cancel];
    [self removeOperation:request.sessionDataTask];
    [request clearCompletionBlock];
}

- (void)cancelAllRequests {
    NSDictionary *copyRecord = [_requestsRecordDictionaryM copy];
    for (NSString *key in copyRecord) {
        WXBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

//JSON 合法性检查
- (BOOL)checkResult:(WXBaseRequest *)request {
    BOOL result = [request statusCodeValidator];
    if (!result) {
        return result;
    }
    id validator = [request jsonValidator];
    if (validator != nil) {
        id json = [request responseJSONObject];
        result = [WXNetworkPrivate checkJson:json withValidator:validator];
    }
    return result;
}

- (void)handleRequestResult:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [self requestHashKey:sessionDataTask];
    WXBaseRequest *request = _requestsRecordDictionaryM[key];
    DLog(@"Finished Request: %@", NSStringFromClass([request class]));
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
            [request toggleAccessoriesWillStopCallBack];
            [request requestCompleteFilter];
            if (request.delegate != nil) {
                [request.delegate requestFinished:request];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        } else {
            DLog(@"Request %@ failed, status code = %ld",
                   NSStringFromClass([request class]), (long)request.responseStatusCode);
            [request toggleAccessoriesWillStopCallBack];
            [request requestFailedFilter];
            if (request.delegate != nil) {
                [request.delegate requestFailed:request];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request);
            }
            [request toggleAccessoriesDidStopCallBack];
        }
    }
    [self removeOperation:sessionDataTask];
    [request clearCompletionBlock];
}

- (NSString *)requestHashKey:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[sessionDataTask hash]];
    return key;
}

- (void)addOperation:(WXBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = [self requestHashKey:request.sessionDataTask];
        @synchronized(self) {
            _requestsRecordDictionaryM[key] = request;
        }
    }
}

- (void)removeOperation:(NSURLSessionDataTask *)operation {
    NSString *key = [self requestHashKey:operation];
    @synchronized(self) {
        [_requestsRecordDictionaryM removeObjectForKey:key];
    }
    DLog(@"Request queue size = %lu", (unsigned long)[_requestsRecordDictionaryM count]);
}

- (NSURLSessionDataTask *)requestOperationWithHTTPMethod:(NSString *)method
                                         requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                                 URLString:(NSString *)URLString
                                                parameters:(id)parameters {
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError) {
        dispatch_async(_manager.completionQueue ?: dispatch_get_main_queue(), ^{
            [self handleRequestResult:nil];
        });
        return nil;
    }
    
    NSURLSessionDataTask *sessionDataTask = [self requestOperationWithRequest:request success:^(NSURLSessionDataTask *_Nonnull task, id responseObject) {
        [self handleRequestResult:task];
    } failure:^(NSURLSessionDataTask *_Nonnull task, NSError *error) {
        [self handleRequestResult:task];
    }];
    
    return sessionDataTask;
}

- (NSURLSessionDataTask *)requestOperationWithRequest:(NSURLRequest *)request
                                                success:(void (^)(NSURLSessionDataTask * _Nonnull task, id responseObject))success
                                                failure:(void (^)(NSURLSessionDataTask * _Nonnull task, NSError *error))failure {
     AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:request.URL];
    manager.responseSerializer = _manager.responseSerializer;
//    manager.shouldUseCredentialStorage = _manager.shouldUseCredentialStorage;
//    manager.credential = _manager.credential;
    manager.securityPolicy = _manager.securityPolicy;
    NSURLSessionDataTask *sessionDataTask = [manager POST:@"" parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        //请求的 uploadProgress
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequestResult:task];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequestResult:task];
    }];

//    [operation setCompletionBlockWithSuccess:success failure:failure];
    manager.completionQueue = _manager.completionQueue;
    manager.completionGroup = _manager.completionGroup;
    
    
    return sessionDataTask;
}

@end
