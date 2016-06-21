//
//  DataServies.h
//  KuaiDian
//
//  Created by eddy on 14-3-10.
//  Copyright (c) 2014年 yintai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kUploadFilesUrl @"http://10.10.11.166:8016/fileManage/UploadFiles"
#define Base_url @"http://116.55.230.234:8082/fatappvl/reqhandler"


@class NetworkManager;

//上传图片接口
//#define kUploadFilesUrl @"api.kd.yintai.pre/fileManage/UploadFiles"

@class DataServies;
typedef void(^RequestFinishBlock) (DataServies *request, id result);
typedef void(^RequestFailBlock) (DataServies *request, NSError *error);

@interface DataServies : NSObject

@property (nonatomic, assign) NetworkManager *manager;

@property(nonatomic, copy)RequestFinishBlock finishBlock;
@property(nonatomic, copy)RequestFailBlock failBlock;

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *httpMethod;
@property (nonatomic, strong) NSMutableDictionary *params;

+ (DataServies *)requestWithURL:(NSString *)url
                         params:(NSMutableDictionary *)params
                     httpMethod:(NSString *)httpMethod
                    finishBlock:(RequestFinishBlock)block
                      failBlock:(RequestFailBlock)failBlock;

+ (DataServies *)requestParams:(NSMutableDictionary *)params
                    withModule:(NSString *)module
                        method:(NSString *)method
                   finishBlock:(RequestFinishBlock)block
                     failBlock:(RequestFailBlock)failBlock;
- (void)sendRequest;
- (void)sendPostRequest;

@end
