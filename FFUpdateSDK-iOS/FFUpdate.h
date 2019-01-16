//
//  FFUpdate.h
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2018/12/29.
//  Copyright © 2018年 wuzhicheng. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FFUpdate : NSObject

+ (void)registerWithAppKey:(NSString *)key;

/**
 自动检查更新
 */
+ (void)checkUpdate;

/**
 检查更新

 @param callback 检查更新
 */
+ (void)checkUpdateWithResult:(void(^)(BOOL needUpdate,NSString *versionName,NSString *msg))callback;


/**
 安装更新
 */
+ (void)installUpdate;

+ (BOOL)isUpdate;


@end
