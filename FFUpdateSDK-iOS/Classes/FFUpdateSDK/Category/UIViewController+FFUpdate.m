//
//  UIViewController+FFUpdate.m
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/8.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import "UIViewController+FFUpdate.h"
#import "FFCordovaResourceUpdate.h"

@implementation UIViewController (FFUpdate)

- (void)cordova_initCDVViewController{
    //wwwFolderName
    //startPage
    //configFile
    NSURL *wwwURL = [FFCordovaResourceUpdate wwwURL];
    NSString *startPage = [FFCordovaResourceUpdate startPage];
    if (startPage.length == 0 || ![[NSFileManager defaultManager] fileExistsAtPath:[wwwURL.path stringByAppendingPathComponent:startPage]]) {
        return;
    }
    SEL wwwFolderNameSEL = NSSelectorFromString(@"setWwwFolderName:");
    SEL startPageSEL = NSSelectorFromString(@"setStartPage:");
    SEL configFileSEL = NSSelectorFromString(@"setConfigFile:");
    if ([self respondsToSelector:wwwFolderNameSEL]) {
        [self performSelector:wwwFolderNameSEL withObject:wwwURL.absoluteString];
    }
    if ([self respondsToSelector:startPageSEL] && startPage.length > 0) {
        [self performSelector:startPageSEL withObject:startPage];
    }
//    NSString *configPath = [wwwURL.path stringByAppendingPathComponent:@"config.xml"];
//    if ([[NSFileManager defaultManager] fileExistsAtPath:configPath]) {
//        if ([self respondsToSelector:configFileSEL]) {
//            [self performSelector:configFileSEL withObject:@"config.xml"];
//        }
//    }
}

@end
