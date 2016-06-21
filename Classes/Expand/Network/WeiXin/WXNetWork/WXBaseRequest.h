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
typedef void(^WXRequestCompletionBlock)(__kindof WXBaseRequest *request);

@protocol WXRequestDelegate <NSObject>

@optional

- (void)requestFinished:(WXBaseRequest *)request;
- (void)requestFailed:(WXBaseRequest *)request;
- (void)clearRequest;

@end

@protocol WXRequestAccessory <NSObject>

@optional

- (void)requestWillStart:(id)request;
- (void)requestWillStop:(id)request;
- (void)requestDidStop:(id)request;

@end

@interface WXBaseRequest : NSObject

/// Tag
@property (nonatomic) NSInteger tag;

/// User info
@property (nonatomic, strong) NSDictionary *userInfo;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

/// request delegate object
@property (nonatomic, weak) id<WXRequestDelegate> delegate;

@property (nonatomic, strong, readonly) NSDictionary *responseHeaders;

@property (nonatomic, strong, readonly) NSData *responseData;

@property (nonatomic, strong, readonly) NSString *responseString;

@property (nonatomic, strong, readonly) id responseJSONObject;

@property (nonatomic, readonly) NSInteger responseStatusCode;

@property (nonatomic, strong, readonly) NSError *requestOperationError;

@property (nonatomic, copy) WXRequestCompletionBlock successCompletionBlock;

@property (nonatomic, copy) WXRequestCompletionBlock failureCompletionBlock;

@property (nonatomic, strong) NSMutableArray *requestAccessories;

/// 请求的优先级, 优先级高的请求会从请求队列中优先出列
@property (nonatomic) WXRequestPriority requestPriority;

/// Return cancelled state of request operation
@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

/// append self to request queue
- (void)start;

/// remove self from request queue
- (void)stop;

- (BOOL)isExecuting;

/// block回调
- (void)startWithCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                                    failure:(WXRequestCompletionBlock)failure;

- (void)setCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                              failure:(WXRequestCompletionBlock)failure;

/// 把block置nil来打破循环引用
- (void)clearCompletionBlock;

/// Request Accessory，可以hook Request的start和stop
- (void)addAccessory:(id<WXRequestAccessory>)accessory;

/// 以下方法由子类继承来覆盖默认值

/// 请求成功的回调
- (void)requestCompleteFilter;

/// 请求失败的回调
- (void)requestFailedFilter;

/// 请求的URL
- (NSString *)requestUrl;

/// 请求的CdnURL
- (NSString *)cdnUrl;

/// 请求的BaseURL
- (NSString *)baseUrl;

/// 请求的连接超时时间，默认为60秒
- (NSTimeInterval)requestTimeoutInterval;

/// 请求的参数列表
- (id)requestArgument;

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

/// 构建自定义的UrlRequest，
/// 若这个方法返回非nil对象，会忽略requestUrl, requestArgument, requestMethod, requestSerializerType
- (NSURLRequest *)buildCustomUrlRequest;

/// 是否使用CDN的host地址
- (BOOL)useCDN;

/// 用于检查JSON是否合法的对象
- (id)jsonValidator;

/// 用于检查Status Code是否正常的方法
- (BOOL)statusCodeValidator;

/// 当POST的内容带有文件等富文本时使用
- (AFConstructingBlock)constructingBodyBlock;

/// 当需要断点续传时，指定续传的地址
- (NSString *)resumableDownloadPath;

/// 当需要断点续传时，获得下载进度的回调
- (AFDownloadProgressBlock)resumableDownloadProgressBlock;


@end
