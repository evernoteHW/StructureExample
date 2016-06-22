//
//  WXKNetworkAgent.h
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXBaseRequest.h"


@interface WXNetworkAgent : NSObject

+ (WXNetworkAgent *)sharedInstance;

- (void)addRequest:(WXBaseRequest *)request;

- (void)cancelRequest:(WXBaseRequest *)request;

- (void)cancelAllRequests;

@end
