//
//  NetworkManager.h
//  KuaiDian
//
//  Created by eddy on 14-5-18.
//  Copyright (c) 2014年 yintai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataServies.h"

@interface NetworkManager : NSObject
{
    
    NSMutableSet *requests;
}

+(NetworkManager *)shareManager;

- (DataServies *)requestWithURL:(NSString *)url
                         params:(NSMutableDictionary *)params
                     httpMethod:(NSString *)httpMethod
                    finishBlock:(RequestFinishBlock)block
                      failBlock:(RequestFailBlock)failBlock;

- (DataServies *)requestParams:(NSMutableDictionary *)params
                    withModule:(NSString *)module
                        method:(NSString *)method
                   finishBlock:(RequestFinishBlock)block
                     failBlock:(RequestFailBlock)failBlock;

- (void)requestDidFinish:(DataServies *)request;

@end
