//
//  FFDeviceInfo.h
//  FFDeviceInfo
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    INSTALL_IPA = 0,
    INSTALL_H5 = 1,
} INSTALL_TYPE;


@interface FFDeviceInfo : NSObject
+ (NSString *)uuid;
+ (NSString *)brand;
+ (NSString *)model;
+ (NSString *)name;
+ (NSString *)systemVersion;


+ (void)reportDeviceInfo;


+ (void)reportInstall:(INSTALL_TYPE)installType appkey:(NSString *)appkey sysVersion:(NSInteger)sysversion;
@end
