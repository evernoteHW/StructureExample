//
//  WXBaseRequest.h
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFImageDownloader.h"

//#import "AFDownloadRequestOperation.h"

@class WXBaseRequest;

typedef NS_ENUM(NSInteger , WXRequestMethod) {
    WXRequestMethodGet = 0,                //Get 方法
    WXRequestMethodPost,                   //Post
    WXRequestMethodHead,                   //Head
    WXRequestMethodPut,                    //Head
    WXRequestMethodDelete,                 //Delete
    WXRequestMethodPatch,                  //Patch
};

typedef NS_ENUM(NSInteger , WXRequestSerializerType) {
    WXRequestSerializerTypeHTTP = 0,
    WXRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger , WXRequestPriority) {
    WXRequestPriorityLow = -4L,
    WXRequestPriorityDefault = 0,
    WXRequestPriorityHigh = 4,
};

typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);
typedef void (^AFDownloadProgressBlock)(NSObject *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);
typedef void(^WXRequestCompletionBlock)(__kindof WXBaseRequest *request,id responseObject);
typedef void(^WXRequestFailuredBlock)(__kindof WXBaseRequest *request,NSError *error);

@protocol WXRequestDelegate <NSObject>

@optional

- (void)requestFinished:(WXBaseRequest *)request responseObject:(id)responseObject;
- (void)requestFailed:(WXBaseRequest *)request error:(NSError *)error;
- (void)clearRequest;

@end


@interface WXBaseRequest : NSObject

@property (nonatomic, copy) NSString *interfaceUserInfo;

@property (nonatomic, strong) NSSet *acceptableContentTypes;
/// User info
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

/// request delegate object
@property (nonatomic, weak) id<WXRequestDelegate> delegate;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, strong, readonly) NSData *responseData;

@property (nonatomic, strong, readonly) NSString *responseString;

@property (nonatomic, strong, readonly) id responseJSONObject;

@property (nonatomic, readonly) NSURLSessionTaskState responseStatusCode;

@property (nonatomic, strong, readonly) NSError *requestOperationError;

@property (nonatomic, copy) WXRequestCompletionBlock successCompletionBlock;

@property (nonatomic, copy) WXRequestFailuredBlock failureCompletionBlock;


//缓存
@property (nonatomic, assign) BOOL isCache;

/// 请求的优先级, 优先级高的请求会从请求队列中优先出列
@property (nonatomic, assign) WXRequestPriority requestPriority;

/// Return cancelled state of request operation
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                                    failure:(WXRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                              failure:(WXRequestCompletionBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// 请求的URL
- (NSString *)requestUrl;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;


/// 用于在cache结果，计算cache文件名时，忽略掉一些指定的参数
- (id)cacheFileNameFilterForRequestArgument:(id)argument;

/// Http请求的方法
- (WXRequestMethod)requestMethod;

/// 请求的SerializerType
- (WXRequestSerializerType)requestSerializerType;

/// 请求的Server用户名和密码
- (NSArray *)requestAuthorizationHeaderFieldArray;

/// 在HTTP报头添加的自定义参数
- (NSDictionary *)requestHeaderFieldValueDictionary;

/// 用于检查JSON是否合法的对象
- (id)jsonValidator;

/// 用于检查Status Code是否正常的方法
- (BOOL)statusCodeValidator;

- (NSDictionary *)makeParameters;


@end
