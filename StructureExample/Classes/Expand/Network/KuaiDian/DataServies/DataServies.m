//
//  DataServies.m
//  KuaiDian
//
//  Created by eddy on 14-3-10.
//  Copyright (c) 2014年 yintai. All rights reserved.
//

#import "DataServies.h"
#import "NetworkManager.h"
#import "RequestDefine.h"
#import "AFNetworking.h"

@implementation DataServies

- (void)dealloc
{
    _manager = nil;
}

+ (DataServies *)requestWithURL:(NSString *)url
                         params:(NSMutableDictionary *)params
                     httpMethod:(NSString *)httpMethod
                    finishBlock:(RequestFinishBlock)block
                      failBlock:(RequestFailBlock)failBlock
{
    DataServies *request = [[DataServies alloc] init];
    
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.finishBlock = block;
    request.failBlock = failBlock;
    
    return request;
}

- (void)sendRequest
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:Base_url parameters:_params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            
            return ;
        }else
        {
            //block调用
            if (_finishBlock) {
                _finishBlock(self, (NSDictionary *)responseObject);
                _finishBlock = nil;
            }
            if (_failBlock) {
                _failBlock = nil;
            }
            
            [_manager requestDidFinish:self];
        }

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        if (_failBlock) {
            _failBlock(self, error);
            _failBlock = nil;
        }
        if (_finishBlock) {
            _finishBlock = nil;
        }
        
        [_manager requestDidFinish:self];

    }];

}

+ (DataServies *)requestParams:(NSMutableDictionary *)params
                    withModule:(NSString *)module
                        method:(NSString *)method
                    finishBlock:(RequestFinishBlock)block
                      failBlock:(RequestFailBlock)failBlock
{
    DataServies *request = [[DataServies alloc] init];
    request.params = params;
    request.finishBlock = block;
    request.failBlock = failBlock;
    
    return request;
}
- (void)sendPostRequest
{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager POST:Base_url parameters:_params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject isKindOfClass:[NSDictionary class]]) {
            
            return ;
        }else
        {
            //block调用
            if (_finishBlock) {
                _finishBlock(self, (NSDictionary *)responseObject);
                _finishBlock = nil;
            }
            if (_failBlock) {
                _failBlock = nil;
            }
            
            [_manager requestDidFinish:self];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
        if (_failBlock) {
            _failBlock(self, error);
            _failBlock = nil;
        }
        if (_finishBlock) {
            _finishBlock = nil;
        }
        
        [_manager requestDidFinish:self];
        
    }];
}
@end

