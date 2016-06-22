//
//  Demo.h
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark -
#pragma mark - Block 定义

typedef void(^RequestSuccessArrayBlock)(NSArray *datas);
typedef void(^RequestSuccessBlock)();
typedef void(^RequestFailureBlock)(NSError *error);

#define kWXDDomain              @"wd.paipai.com"
#define kPPDomain               @".paipai.com"
#define kWGDomain               @".wanggou.com"

#pragma mark -
#pragma mark - 全局网络错误通知

static NSString * const kNetworkProtocolErrorNotification = @"kNetworkProtocolErrorNotification";                   // 协议错误，错误码-1
static NSString * const kNetworkDidNotLoggedNotification = @"kNetworkDidNotLoggedNotification";                     // 未登录，错误码1
static NSString * const kNetworkLoginInterfaceErrorNotification = @"kNetworkLoginInterfaceErrorNotification";       // 登录接口调用异常，错误码10000
static NSString * const kNetworkParametersErrorNotification = @"kNetworkParametersErrorNotification";               // 参数异常，错误码10008
static NSString * const kNetworkPermissionDeniedNotification = @"kNetworkPermissionDeniedNotification";             // 没有权限调用该接口，错误码10015
static NSString * const kApplicationDidReceiveRemoteNotification = @"kApplicationDidReceiveRemoteNotification";     // 从推送消息中启动
static NSString * const kWxPayJumpToOrderFinish = @"kWxPayJumpToOrderFinish";                                       // 微信支付成功
static NSString * const kWxPayJumpToOrderError = @"kWxPayJumpToOrderError";                                         // 微信支付失败
static NSString * const kUserDidLoginNotification = @"kUserDidLoginNotification";// 用户登录成功
