//
//  MacrosPublicHeader.h
//  SUIMVVMDemo
//
//  Created by yuantao on 16/3/6.
//  Copyright © 2016年 lovemo. All rights reserved.
//

#ifndef MacrosPublicHeader_h
#define MacrosPublicHeader_h

//DEBUG  模式下打印日志,当前行
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

//获取系统版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]
#define CurrentSystemVersion [[UIDevice currentDevice] systemVersion]

//判断设备的操做系统是不是ios7
#define IOS7 ([[[UIDevice currentDevice].systemVersion doubleValue] >= 7.0]

//获取当前屏幕的高度
#define kScreenHeight ([UIScreen mainScreen].applicationFrame.size.height)

//获取当前屏幕的宽度
#define kScreenWidth  ([UIScreen mainScreen].applicationFrame.size.width)

// rgb颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//带有RGBA的颜色设置
#define RGBA(R, G, B, A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

//NSUserDefaults 实例化
#define USER_DEFAULT [NSUserDefaults standardUserDefaults]

//////////////////////////////单例化一个类
#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
\
+ (classname *)shared##classname { \
    @synchronized(self) { \
        if (shared##classname == nil) { \
            shared##classname = [[self alloc] init]; \
        } \
      } \
    return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone { \
    @synchronized(self) { \
        if (shared##classname == nil) { \
            shared##classname = [super allocWithZone:zone]; \
            return shared##classname; \
        } \
    } \
    return nil; \
} \
- (id)copyWithZone:(NSZone *)zone { \
    return self; \
}
//////////////////////////////

#endif /* MacrosPublicHeader_h */
