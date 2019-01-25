//
//  CordovaResourceUpdate.h
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIViewController+FFUpdate.h"
#import <UIKit/UIKit.h>
@interface FFCordovaResourceUpdate : NSObject

+ (void)registerWithAppKey:(NSString *)key;

/**
 检查更新

 @param vc 主控制器
 */
+ (void)checkUpdateWithViewController:(UIViewController *)vc;

/**
 设置当前版本

 @param currentVersion 当前版本指的是在后台中的系统版本号
 */
+ (void)setCurrentVersion:(NSInteger)currentVersion;


/**
 初始化主页

 @param index 主页相对www路径
 */
+ (void)setStartPage:(NSString *)index;

+ (NSString *)startPage;

+ (UIViewController *)mainViewController;

+ (NSInteger)currentHtmlVersion;

+ (NSURL *)zipTempURL;
+ (NSURL *)wwwURL;
+ (NSString *)appkey;

@end
