//
//  NetworkManager.m
//  KuaiDian
//
//  Created by eddy on 14-5-18.
//  Copyright (c) 2014年 yintai. All rights reserved.
//

#import "NetworkManager.h"
#import "RequestDefine.h"

@implementation NetworkManager

static NetworkManager *instance = nil;
+(NetworkManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[NetworkManager alloc] init];
    });
    
    return instance;
}

-(id)init
{
    if (self = [super init]) {
        requests = [[NSMutableSet alloc] init];
    }
    
    return self;
}


- (DataServies *)requestWithURL:(NSString *)url
                         params:(NSMutableDictionary *)params
                     httpMethod:(NSString *)httpMethod
                    finishBlock:(RequestFinishBlock)block
                      failBlock:(RequestFailBlock)failBlock
{
    DataServies *dtServices = [DataServies requestWithURL:url
                                                 params:params
                                             httpMethod:httpMethod
                                            finishBlock:block
                                              failBlock:failBlock];
    dtServices.manager = self;
    [requests addObject:dtServices];
    
    
    [dtServices sendRequest];
    return dtServices;

}

- (DataServies *)requestParams:(NSMutableDictionary *)params
                    withModule:(NSString *)module
                        method:(NSString *)method
                   finishBlock:(RequestFinishBlock)block
                     failBlock:(RequestFailBlock)failBlock
{
    DataServies *dtServices = [DataServies requestParams:params
                                              withModule:module
                                                  method:method
                                             finishBlock:block
                                               failBlock:failBlock];
 
    dtServices.manager = self;
    [requests addObject:dtServices];
    
    
    [dtServices sendPostRequest];
    return dtServices;
}

- (void)requestDidFinish:(DataServies *)request
{
    [requests removeObject:request];
    request.manager = nil;
}

@end
