//
//  HTTPRequest.m
//  WXD
//
//  Created by Fantasy on 11/12/14.
//  Copyright (c) 2014 JD.COM. All rights reserved.
//

#import "HTTPRequest.h"
#import <objc/runtime.h>


@implementation HTTPRequest

- (NSDictionary *)makeParameters
{
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
                                NSDictionary *dic = [self dictionaryRecordPropertyWithIgnore:@"success"];
                                [array addObject:dic];
                            }
                        }
                        [dictionaryFormat setObject:array forKey:key];
                    }
                    else {
                        // NSDictionary和自定义类型
                        NSDictionary *dic = [value dictionaryRecordPropertyWithIgnore:@"success"];
                        [dictionaryFormat setObject:dic forKey:key];
                    }
                }
            }
                break;
            
            case '[':   // array
            {
                // 数组
                NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:[value count]];
                
                for (__unused NSObject *obj in value) {
                    NSDictionary *dic = [self dictionaryRecordPropertyWithIgnore:@"success"];
                    [array addObject:dic];
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
    
    [dictionaryFormat setObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"timestamp"];
    
    return dictionaryFormat;
}

- (NSDictionary *)dictionaryRecordPropertyWithIgnore:(NSString *)ignoreName
{
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    
    for (int i = 0; i < count; i++) {
        NSString *key = [NSString stringWithUTF8String:property_getName(properties[i])];
        
        if ([ignoreName compare:key] == NSOrderedSame) {
            continue;
        }
        
        id value = [self valueForKey:key];
        
        if ([value isKindOfClass:[NSArray class]]) {
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
                    // NSDictionary或自定义类型
                    NSDictionary *dic = [self dictionaryRecordPropertyWithIgnore:@"success"];
                    [array addObject:dic];
                }
            }
            [dictionary setObject:array forKey:key];
        }
        else if (value) {
            // 写入数据
            [dictionary setObject:value forKey:key];
        }
        else {
            // 默认为空
            [dictionary setObject:@"" forKey:key];
        }
    }
    
    return dictionary;
}


- (void)handleResponse:(id)responseObject
{
    NSLog(@"%@ Response Type = %@ = %@", NSStringFromClass([self class]), NSStringFromClass([responseObject class]), responseObject);
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *json = responseObject;
        
        NSInteger code = -1;
        if ([json objectForKey:@"retCode"]) {
            code = [[json objectForKey:@"retCode"] intValue];
        }
        else {
            code = [[json objectForKey:@"ret"] intValue];
        }
        
        if (code == 0 || code == 10108) {
            @try {
                [self onResponse:json];
            }
            @catch (NSException *exception) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handleProtocolError];
                });
            }
        }
        else {
            NSString *errorMessage = [json objectForKey:@"err"];
            if (errorMessage) {
                NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
                NSError *error = [NSError errorWithDomain:kWXDDomain code:code userInfo:userInfo];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (![self handleCommonError:error]) {
                        
                    }
                    [self onError:error];
                });
            }
        }
    }
    else if ([responseObject isKindOfClass:[NSData class]]) {
        // JSONP接口
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:gbkEncoding];
        
        NSRange beginRange = [responseString rangeOfString:@"({"];
        NSRange endRange = [responseString rangeOfString:@"})"];
        
        NSRange range = NSMakeRange(beginRange.location + 2, endRange.location - beginRange.location - 2);
        
        NSString *jsonString = [[responseString substringWithRange:range] stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        
        NSString *fixedString = [self fixJSONString:jsonString];
        
        NSData *jsonData = [fixedString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        
        if (jsonDic) {
            [self onResponse:jsonDic];
        }
        else {
            NSString *errorMessage = @"协议错误，请检查接口返回数据是否正确";
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
            NSError *error = [NSError errorWithDomain:kWXDDomain code:-1 userInfo:userInfo];
            [self onError:error];
        }
    }
    else {
        NSString *errorMessage = @"网络异常，请稍后重试";
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:kWXDDomain code:-1 userInfo:userInfo];
        [self onError:error];
    }
}

- (NSString *)fixJSONString:(NSString *)jsonString
{
    NSMutableString *fixedString = [[NSMutableString alloc] initWithString:@"{"];
    NSArray *array = [jsonString componentsSeparatedByString:@","];
    for (NSInteger i = 0; i < [array count]; i++) {
        NSString *item = [array objectAtIndex:i];
        
        NSArray *itemArray = [item componentsSeparatedByString:@":"];
        if ([itemArray count] == 2)
        {
            if (i < [array count] - 1) {
                [fixedString appendFormat:@"\"%@\":%@, ", [itemArray objectAtIndex:0], [itemArray objectAtIndex:1]];
            }
            else {
                [fixedString appendFormat:@"\"%@\":%@", [itemArray objectAtIndex:0], [itemArray objectAtIndex:1]];
            }
        }
        else     
        {
            NSRange range = [item rangeOfString:@"StepRemark:"];
            if(range.location != NSNotFound)
            {
                NSString *stepStr = [item substringFromIndex:10];
                [fixedString appendFormat:@"\"StepRemark\"%@", stepStr];
            }
        }
    }
    
    [fixedString appendString:@"}"];
    
    return fixedString;
}

- (BOOL)handleCommonError:(NSError *)error
{
    NSInteger code = error.code;
    
    switch (code) {
        case 1:
            // 未登录
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkDidNotLoggedNotification object:error];
            break;
            
        case 10000: // 登录接口调用异常
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkLoginInterfaceErrorNotification object:error];
            break;
            
        case 10008: // 参数异常
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkParametersErrorNotification object:error];
            break;
            
        case 10015: // 没有权限调用该接口
            [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkPermissionDeniedNotification object:error];
            break;
            
        default:
            // 不是全局错误
            return NO;
    }
    
    return YES;
}

- (void)handleProtocolError
{
    // 协议错误
    NSString *errorMessage = @"协议错误，请检查接口返回数据是否正确。";
    NSInteger code = -1;
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:kWXDDomain code:code userInfo:userInfo];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNetworkProtocolErrorNotification object:error];
}

- (void)handleError:(NSError *)error
{
    if (![self handleCommonError:error]) {
        // 全局错误不继续向外传递
        if (error.code == 3840) {
            // 返回的数据无法解析为JSON
            NSString *errorMessage = @"网络异常，请稍后再试。";
            NSInteger code = 3840;
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:errorMessage forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:kWXDDomain code:code userInfo:userInfo];
        }
        [self onError:error];
    }
}

#pragma mark -
#pragma mark - Virtual

- (NSString *)interface
{
    return _interfaceURL;
}

- (void)onResponse:(NSDictionary *)json
{
    
}

- (void)onError:(NSError *)error
{
    if (self.failure) {
        self.failure(error);
    }
}

@end
