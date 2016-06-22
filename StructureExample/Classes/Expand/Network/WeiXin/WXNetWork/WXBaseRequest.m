//
//  WXBaseRequest.m
//  StructureExample
//
//  Created by WeiHu on 6/21/16.
//  Copyright © 2016 WeiHu. All rights reserved.
//

#import "WXBaseRequest.h"
#import "WXNetworkAgent.h"
#import <objc/runtime.h>

@implementation WXBaseRequest


////////////////////////////////////////////////////////////////////////////////////
//请求 AFNetworking 参数配置
- (NSString *)requestUrl {
    return @"";
}

- (NSString *)baseUrl {
    return @"";
}
- (NSSet *)acceptableContentTypes{
    return [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", nil];
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}
- (NSArray *)requestAuthorizationHeaderFieldArray {
    return nil;
}

- (NSDictionary *)requestHeaderFieldValueDictionary {
    return nil;
}

- (WXRequestMethod)requestMethod {
    return WXRequestMethodGet;
}

- (WXRequestSerializerType)requestSerializerType {
    return WXRequestSerializerTypeHTTP;
}
////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary *)makeParameters{
    NSMutableDictionary *dictionaryFormat = [NSMutableDictionary dictionary];
    
    // 取得当前类类型
    Class cls = [self class];
    
    unsigned int ivarsCnt = 0;
    // 获取类成员变量列表，ivarsCnt为类成员数量
    Ivar *ivars = class_copyIvarList(cls, &ivarsCnt);
    
    // 遍历成员变量列表，其中每个变量都是Ivar类型的结构体
    for (const Ivar *p = ivars; p < ivars + ivarsCnt; ++p)
    {
        Ivar const ivar = *p;
        
        //　获取变量名
        NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
        // 若此变量未在类结构体中声明而只声明为Property，则变量名加前缀 '_'下划线
        // 比如@property(retain) NSString *abc;则key == _abc;
        if ([key hasPrefix:@"_"]) {
            key = [key substringFromIndex:1];
        }
        
        if ([key compare:@"success"] == NSOrderedSame) {
            // 回调函数不作为参数
            continue;
        }
        
        // 获取变量值
        id value = [self valueForKey:key];
        
        // 取得变量类型
        // 通过type[0]可以判断其具体的内置类型
        const char *type = ivar_getTypeEncoding(ivar);
        
        switch (type[0]) {
            case 'c':   // 字符型
            case 'i':   // int
            case 's':   // short
            case 'l':   // long
            case 'q':   // long long
            case 'C':   // unsigned char
            case 'I':   // unsigned int
            case 'S':   // unsigned short
            case 'L':   // unsigned long
            case 'Q':   // unsigned long long
            case 'f':   // float
            case 'd':   // double
            case 'B':   // bool
            {
                // 系统自带类型
                if (value) {
                    [dictionaryFormat setObject:value forKey:key];
                }
            }
                break;
            case '@':   // object
            {
                // 系统自带类型
                if (value) {
                    if ([value isKindOfClass:[NSString class]] ||
                        [value isKindOfClass:[NSNumber class]] ||
                        [value isKindOfClass:[NSNull class]]) {
                        // 系统支持的类型
                        [dictionaryFormat setObject:value forKey:key];
                    }
                    else if ([value isKindOfClass:[NSArray class]]) {
                        // 数组
                        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[value count]];
                        
                        for (NSObject *obj in value) {
                            if ([obj isKindOfClass:[NSString class]] ||
                                [obj isKindOfClass:[NSNumber class]] ||
                                [obj isKindOfClass:[NSNull class]]) {
                                // 系统支持的类型
                                [array addObject:obj];
                            }
                            else {
//                                NSDictionary *dic = [self dictionaryRecordPropertyWithIgnore:@"success"];
//                                [array addObject:dic];
                            }
                        }
                        [dictionaryFormat setObject:array forKey:key];
                    }
                    else {
                        // NSDictionary和自定义类型
//                        NSDictionary *dic = [value dictionaryRecordPropertyWithIgnore:@"success"];
//                        [dictionaryFormat setObject:dic forKey:key];
                    }
                }
            }
                break;
                
            case '[':   // array
            {
                // 数组
                NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[value count]];
                
                for (__unused NSObject *obj in value) {
//                    NSDictionary *dic = [self dictionaryRecordPropertyWithIgnore:@"success"];
//                    [array addObject:dic];
                }
                
                [dictionaryFormat setObject:array forKey:key];
            }
                break;
                
            case 'v':   // void
            case '*':   // char *
            case '#':   // Class
            case ':':   // Selector
            case '{':   // struct
            case '(':   // union
            case 'b':   // bit field
            case '^':   // pointer to type
            case '?':   // unknown
            default:
            {
                // 无法解析的类型
            }
                break;
        }
    }
    
    return dictionaryFormat;

}

- (id)cacheFileNameFilterForRequestArgument:(id)argument {
    return argument;
}

- (id)jsonValidator {
    return nil;
}
- (BOOL)statusCodeValidator {
    return NO;
}

///////////////////////////////////Request/////////////////////////////////////////////////
- (void)start {
    [[WXNetworkAgent sharedInstance] addRequest:self];
}
/// remove self from request queue
- (void)stop {
    self.delegate = nil;
    [[WXNetworkAgent sharedInstance] cancelRequest:self];
}


- (void)startWithCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                                    failure:(WXRequestCompletionBlock)failure {
    [self setCompletionBlockWithSuccess:success failure:failure];
    [self start];
}

- (void)setCompletionBlockWithSuccess:(WXRequestCompletionBlock)success
                              failure:(WXRequestCompletionBlock)failure {
    
    self.successCompletionBlock = success;
    self.failureCompletionBlock = failure;
}

- (void)clearCompletionBlock {
    // nil out to break the retain cycle.
    self.successCompletionBlock = nil;
    self.failureCompletionBlock = nil;
}

//////////////////////////////////////Cache////////////////////////////////////////////////


///////////////////////////////////////////////////////////////////////////////////////////
@end
