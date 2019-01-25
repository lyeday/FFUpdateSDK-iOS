//
//  UIViewController+FFUpdate.h
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/8.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CDVViewController;

@interface UIViewController (FFUpdate)

/**
 初始化cordova 控制器配置
 */
- (void)cordova_initCDVViewController;

@end
