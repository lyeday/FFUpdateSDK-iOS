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

/**
 上报安装

 @param installType 安装类型
 @param appkey appkey description
 @param sysversion sysversion description
 @param type 0:首次安装,1:更新安装
 */
+ (void)reportInstall:(INSTALL_TYPE)installType appkey:(NSString *)appkey sysVersion:(NSInteger)sysversion type:(NSInteger)type;
@end
