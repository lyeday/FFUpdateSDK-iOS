//
//  H5UpdateViewController.h
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface H5UpdateViewController : UIViewController

/** 升级的界面 */
@property (nonatomic,weak) UIView *updateView;

/** 更新数据 */
@property (nonatomic,strong) NSDictionary *data;

@end
