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
    NSMutableDictionary *_requestsRecordDictionaryM;
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

#pragma mark -
#pragma mark - Start Request

- (void)startRequest:(WXBaseRequest *)request
{
    NSDictionary *params = [request makeParameters];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:request.baseUrl]];
    NSStringEncoding charsetEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.acceptableContentTypes = [request acceptableContentTypes];
    manager.responseSerializer.stringEncoding = charsetEncoding;
    manager.requestSerializer.stringEncoding = charsetEncoding;
    
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        NSMutableArray *mutablePairs = [NSMutableArray array];
        NSString *paramString = [mutablePairs componentsJoinedByString:@"&"];
        return paramString;
    }];

    NSURLSessionDataTask *dataTask = nil;
    __weak WXNetworkAgent *weakSelf = self;
    
    
    switch (request.requestMethod) {
    //GET
        case WXRequestMethodGet:{
            dataTask = [manager GET:request.requestUrl parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                WXNetworkAgent *strongSelf = weakSelf;
                [strongSelf handleSuccessResult:task responseObject:responseObject];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                WXNetworkAgent *strongSelf = weakSelf;
                [strongSelf handleFailureResult:task error:error];
            }];
        }
            break;
    //POST
        case WXRequestMethodPost:{
            dataTask = [manager POST:request.requestUrl parameters:params
                                      progress:nil
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                                           WXNetworkAgent *strongSelf = weakSelf;
                                           [strongSelf handleSuccessResult:task responseObject:responseObject];
                                       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                                           WXNetworkAgent *strongSelf = weakSelf;
                                           [strongSelf handleFailureResult:task error:error];

                                       }];
        }
            break;
        default:
            break;
    }
    request.sessionDataTask = dataTask;
    [self addSessionDataTask:request];
    
    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DLog(@"Get %@ URL = %@: param = %@", NSStringFromClass([request class]), [request requestUrl], paramsString);
  
}

//检查JSON 合法性

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

- (void)handleSuccessResult:(NSURLSessionDataTask * _Nonnull )sessionDataTask responseObject:(id  _Nullable)responseObject {
    NSString *key = [self requestHashKey:sessionDataTask];
    WXBaseRequest *request = _requestsRecordDictionaryM[key];
    DLog(@"Finished Request: %@", NSStringFromClass([request class]));
    if (request) {
        BOOL succeed = [self checkResult:request];
        if (succeed) {
        
            //二者取 其一
            if (request.delegate != nil) {
                [request.delegate requestFinished:request responseObject:responseObject];
            }
            if (request.successCompletionBlock) {
                request.successCompletionBlock(request,responseObject);
            }
            
        } else {
            DLog(@"Request %@ failed, status code = %ld",
                   NSStringFromClass([request class]), (long)request.responseStatusCode);
            
            //二者取 其一
            
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"JSON IS Valid"                                                                      forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:@"" code:1004 userInfo:userInfo];
            
            if (request.delegate != nil) {
                [request.delegate requestFailed:request error:error];
            }
            if (request.failureCompletionBlock) {
                request.failureCompletionBlock(request,error);
            }
            
        }
    }
    [self removeSessionDataTask:sessionDataTask];
    [request clearCompletionBlock];
}
- (void)handleFailureResult:( NSURLSessionDataTask * _Nonnull )sessionDataTask error:(NSError * _Nonnull)error{
    NSString *key = [self requestHashKey:sessionDataTask];
    WXBaseRequest *request = _requestsRecordDictionaryM[key];
    DLog(@"Finished Request: %@", NSStringFromClass([request class]));
    NSString* errResponse = [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding];
    DLog(@"%@",errResponse);
    
    if (request) {
        DLog(@"Request %@ failed, status code = %ld",NSStringFromClass([request class]), (long)request.responseStatusCode);
    
        if (request.delegate != nil) {
            [request.delegate requestFailed:request error:error];
        }
        
        if (request.failureCompletionBlock) {
            request.failureCompletionBlock(request,error);
        }
    }
    [self removeSessionDataTask:sessionDataTask];
    [request clearCompletionBlock];
}
#pragma mark - URL 非法性检查

- (NSString *)buildRequestUrl:(WXBaseRequest *)request {
    NSString *detailUrl = [request requestUrl];
    if ([detailUrl hasPrefix:@"http"]) {
        return detailUrl;
    }
    if ([detailUrl hasPrefix:@"https"]) {
        return detailUrl;
    }
    return [NSString stringWithFormat:@"%@%@", [request baseUrl], detailUrl];
}


#pragma mark - 取消请求
- (void)addRequest:(WXBaseRequest *)request{
    
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == WXRequestSerializerTypeHTTP) {
        //非JOSN 数据
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == WXRequestSerializerTypeJSON) {
        //JSON 数据
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
    [self startRequest:request];

}

- (void)cancelRequest:(WXBaseRequest *)request{
    [request.sessionDataTask cancel];
    [self removeSessionDataTask:request.sessionDataTask];
    [request clearCompletionBlock];
}
- (void)cancelAllRequests{
    NSDictionary *copyRecord = [_requestsRecordDictionaryM copy];
    for (NSString *key in copyRecord) {
        WXBaseRequest *request = copyRecord[key];
        [request stop];
    }
}

- (NSString *)requestHashKey:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[sessionDataTask hash]];
    return key;
}

- (void)addSessionDataTask:(WXBaseRequest *)request {
    if (request.sessionDataTask != nil) {
        NSString *key = [self requestHashKey:request.sessionDataTask];
        @synchronized(self) {
            _requestsRecordDictionaryM[key] = request;
        }
    }
}
- (void)removeSessionDataTask:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [self requestHashKey:sessionDataTask];
    @synchronized(self) {
        [_requestsRecordDictionaryM removeObjectForKey:key];
    }
    DLog(@"Request queue size = %lu", (unsigned long)[_requestsRecordDictionaryM count]);
}


#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
