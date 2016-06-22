//
//  HTTPRequest.h
//  WXD
//
//  Created by Fantasy on 11/12/14.
//  Copyright (c) 2014 JD.COM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PaiPaiConstant.h"

@interface HTTPRequest : NSObject {
    
}
@property (nonatomic, copy) NSString *interfaceURL;
@property (nonatomic, copy) NSString *interfaceUserInfo;
@property (nonatomic, copy) RequestFailureBlock failure;

- (NSString *)interface;
- (NSDictionary *)makeParameters;

- (void)handleResponse:(id)responseObject;
- (void)handleError:(NSError *)error;
- (void)onResponse:(NSDictionary *)json;

@end
