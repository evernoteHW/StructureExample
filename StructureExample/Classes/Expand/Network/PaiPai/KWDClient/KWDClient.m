//
//  KWDClient.m
//  WXD
//
//  Created by Fantasy on 11/11/14.
//  Copyright (c) 2014 JD.COM. All rights reserved.
//

#import "KWDClient.h"
#import "AFNetworking.h"
#import "AppDelegate.h"
#import "HTTPRequest.h"
#import "RequestDefine.h"
#import "HTTPRequest.h"

@interface KWDClient (){
    NSMutableDictionary *_requestsRecordDictionaryM;
}
@property (nonatomic, strong) AFHTTPSessionManager *gbkManager;
@property (nonatomic, strong) AFHTTPSessionManager *utf8Manager;
@property (nonatomic, strong) AFHTTPSessionManager *jsonManager;

@end

@implementation KWDClient

+ (instancetype)shareInstance
{
    static KWDClient *client = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[self alloc] init];
    });
    
    return client;
}

- (instancetype)init
{
    if (self = [super init]) {
        _wdBaseURL = kWDInterfaceBaseURL;
        _requestsRecordDictionaryM = [NSMutableDictionary dictionary]
        ;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    
    return self;
}
- (void)addRequest:(HTTPRequest *)request{

}
- (void)cancelRequest:(HTTPRequest *)request{

}
- (void)cancelAllRequests{
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (AFHTTPSessionManager *)gbkManager
{
    if (!_gbkManager)
        _gbkManager = [[AFHTTPSessionManager alloc] init];
    NSStringEncoding charsetEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    _gbkManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
    _gbkManager.responseSerializer.stringEncoding = charsetEncoding;
    _gbkManager.requestSerializer.stringEncoding = charsetEncoding;
    _gbkManager.requestSerializer.timeoutInterval = kTimeOutInterVal;
    
    // UserAgent
    NSString *userAgent = [_gbkManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"];
    if ([userAgent rangeOfString:kUserAgentPPSNS].location == NSNotFound) {
        userAgent = [[NSString alloc] initWithFormat:@"%@ / %@", [_gbkManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], kUserAgentPPSNS];
    }
    if ([userAgent rangeOfString:kUserAgentiOSApp].location == NSNotFound) {
        userAgent = [[NSString alloc] initWithFormat:@"%@ / %@", [_gbkManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], kUserAgentiOSApp];
    }
    [_gbkManager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [_gbkManager.requestSerializer setValue:@"http://xd.paipai.com" forHTTPHeaderField:@"referer"];
    
    [_gbkManager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        NSMutableArray *mutablePairs = [NSMutableArray array];
        NSString *paramString = [mutablePairs componentsJoinedByString:@"&"];
        NSLog(@"paramString = %@", paramString);
        
        return paramString;
    }];
    
    return _gbkManager;
}

- (AFHTTPSessionManager *)utf8Manager
{
    if (!_utf8Manager)
        _utf8Manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kWDInterfaceBaseURL]];
    NSStringEncoding charsetEncoding = NSUTF8StringEncoding;
    _utf8Manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
    _utf8Manager.responseSerializer.stringEncoding = charsetEncoding;
    _utf8Manager.requestSerializer.stringEncoding = charsetEncoding;
    
    // UserAgent
    NSString *userAgent = [_utf8Manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"];
    if ([userAgent rangeOfString:kUserAgentPPSNS].location == NSNotFound) {
        userAgent = [[NSString alloc] initWithFormat:@"%@ / %@", [_utf8Manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], kUserAgentPPSNS];
    }
    if ([userAgent rangeOfString:kUserAgentiOSApp].location == NSNotFound) {
        userAgent = [[NSString alloc] initWithFormat:@"%@ / %@", [_utf8Manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], kUserAgentiOSApp];
    }
    [_utf8Manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [_utf8Manager.requestSerializer setValue:@"http://xd.paipai.com" forHTTPHeaderField:@"referer"];
    
    [_utf8Manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        NSMutableArray *mutablePairs = [NSMutableArray array];

        NSString *paramString = [mutablePairs componentsJoinedByString:@"&"];
        
        return paramString;
    }];
    
    return _utf8Manager;
}

- (AFHTTPSessionManager *)jsonManager
{
    if (!_jsonManager)
        _jsonManager = [[AFHTTPSessionManager alloc] init];
    NSStringEncoding charsetEncoding = NSUTF8StringEncoding;
    _jsonManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
    _jsonManager.responseSerializer.stringEncoding = charsetEncoding;
    _jsonManager.requestSerializer.stringEncoding = charsetEncoding;
    
    // UserAgent
    NSString *userAgent = [_jsonManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"];
    if ([userAgent rangeOfString:kUserAgentPPSNS].location == NSNotFound) {
        userAgent = [[NSString alloc] initWithFormat:@"%@ / %@", [_jsonManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], kUserAgentPPSNS];
    }
    if ([userAgent rangeOfString:kUserAgentiOSApp].location == NSNotFound) {
        userAgent = [[NSString alloc] initWithFormat:@"%@ / %@", [_jsonManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], kUserAgentiOSApp];
    }
    [_jsonManager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [_jsonManager.requestSerializer setValue:@"http://xd.paipai.com" forHTTPHeaderField:@"referer"];
    _jsonManager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    return _jsonManager;
}

- (NSDictionary *)makeParameters:(NSDictionary *)parameters
{
    if (!_commonParameters) {
        // 初始化公共参数
        _commonParameters = [NSMutableDictionary dictionary];
        [_commonParameters setValue:@"ppsns" forKey:@"source"];
    }
    // 添加公共参数
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:_commonParameters];
    // 添加接口参数
    [param addEntriesFromDictionary:parameters];
    
    return param;
}


#pragma mark -
#pragma mark - Start Request

- (NSURLSessionDataTask *)startRequest:(HTTPRequest *)request
{
    NSDictionary *params = [self makeParameters:[request makeParameters]];
    NSURLSessionDataTask *dataTask = [[self utf8Manager] POST:request.interface parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [request handleResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [request handleError:error];
    }];
    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Post %@ URL = %@: param = %@", NSStringFromClass([request class]), [request interface], paramsString);
    
    return dataTask;
}

- (NSURLSessionDataTask *)startGetRequest:(HTTPRequest *)request
{
    NSDictionary *params = [self makeParameters:[request makeParameters]];
    
    NSURLSessionDataTask *dataTask = [[self utf8Manager] GET:request.interface parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [request handleResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [request handleError:error];
    }];

    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Get %@ URL = %@: param = %@", NSStringFromClass([request class]), [request interface], paramsString);
    
    return dataTask;
}

- (NSURLSessionDataTask *)startGBKRequest:(HTTPRequest *)request
{
    NSDictionary *params = [self makeParameters:[request makeParameters]];
    
    NSURLSessionDataTask *dataTask = [[self gbkManager] GET:request.interface parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [request handleResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [request handleError:error];
    }];

    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Post GBK %@ URL = %@: param = %@", NSStringFromClass([request class]), [request interface], paramsString);
    
    return dataTask;
}

- (NSURLSessionDataTask *)startGBKGetRequest:(HTTPRequest *)request
{
    NSDictionary *params = [self makeParameters:[request makeParameters]];
    
    NSURLSessionDataTask *dataTask = [[self gbkManager] GET:request.interface parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [request handleResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [request handleError:error];
    }];
    
    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Get GBK %@ URL = %@: param = %@", NSStringFromClass([request class]), [request interface], paramsString);
    
    return dataTask;
}

- (NSURLSessionDataTask *)startJSONRequest:(HTTPRequest *)request
{
    NSDictionary *params = [self makeParameters:[request makeParameters]];
    
    NSURLSessionDataTask *dataTask = [[self jsonManager] POST:request.interface parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [request handleResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [request handleError:error];
    }];

    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Post JSON %@ URL = %@: param = %@", NSStringFromClass([request class]), [request interface], paramsString);
    
    return dataTask;
}

- (NSURLSessionDataTask *)startGetJSONRequest:(HTTPRequest *)request
{
    NSDictionary *params = [self makeParameters:[request makeParameters]];
    
    NSURLSessionDataTask *dataTask = [[self jsonManager] GET:request.interface parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [request handleResponse:responseObject];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [request handleError:error];
    }];

    // Debug
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:NSJSONWritingPrettyPrinted error:&error];
    NSString *paramsString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Get JSON %@ URL = %@: param = %@", NSStringFromClass([request class]), [request interface], paramsString);
    
    return dataTask;
}

- (NSString *)requestHashKey:(NSURLSessionDataTask *)sessionDataTask {
    NSString *key = [NSString stringWithFormat:@"%lu", (unsigned long)[sessionDataTask hash]];
    return key;
}




@end
