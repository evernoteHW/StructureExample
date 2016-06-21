//
//  WXNetworkPrivate.h
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXBaseRequest.h"

@interface WXNetworkPrivate : NSObject


+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary *)parameters;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

@end

@interface WXBaseRequest (RequestAccessory)

- (void)toggleAccessoriesWillStartCallBack;
- (void)toggleAccessoriesWillStopCallBack;
- (void)toggleAccessoriesDidStopCallBack;

@end

//@interface WXBatchRequest (RequestAccessory)
//
//- (void)toggleAccessoriesWillStartCallBack;
//- (void)toggleAccessoriesWillStopCallBack;
//- (void)toggleAccessoriesDidStopCallBack;
//
//@end
//
//@interface WXChainRequest (RequestAccessory)
//
//- (void)toggleAccessoriesWillStartCallBack;
//- (void)toggleAccessoriesWillStopCallBack;
//- (void)toggleAccessoriesDidStopCallBack;
//
//@end
