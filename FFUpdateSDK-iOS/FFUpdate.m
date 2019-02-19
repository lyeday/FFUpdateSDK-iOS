//
//  FFUpdate.m
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2018/12/29.
//  Copyright © 2018年 wuzhicheng. All rights reserved.
//

#import "FFUpdate.h"
#import <UIKit/UIKit.h>
#import "FFUpdateNetwork.h"
#import "FFDeviceInfo.h"
#import <CommonCrypto/CommonDigest.h>

//#define FFLog(fmt,...) NSLog((@"FFUpdateSDK:"fmt), ##__VA_ARGS__); \
//[[NSNotificationCenter defaultCenter] postNotificationName:@"FF_NOTIFICATION" object:[NSString stringWithFormat:fmt,##__VA_ARGS__]]
#define FFLog(fmt,...)

#define LAST_INSTALL_MD5         @"__FFUPDATE_INSTALL_MD5"               //最后安装时间
#define CURRENT_VERSION           @"__FFUPDATE_CURRENT_VERSION"            //当前的版本号
#define READY_UPDATE_VERSION      @"__FFUPDATE_READY_UPDATE_VERSION"       //预升级的版本

#define F_MGR                     [NSFileManager defaultManager]  //文件管理器
#define U_DEF                     [NSUserDefaults standardUserDefaults]  //数据

@interface FFUpdate()<UIAlertViewDelegate>

/** app key */
@property (nonatomic,copy) NSString *appKey;

/** 安装的地址 */
@property (nonatomic,copy) NSString *installUrl;

/** 是否第一次安装app */
@property (nonatomic,assign) BOOL firstInstall;

/** 是否正在更新 */
@property (nonatomic,assign) BOOL isUpdate;

@end

@implementation FFUpdate

- (void)installUpdate{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.installUrl] options:@{} completionHandler:^(BOOL success) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                exit(0);
            });
        }];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.installUrl]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    }
}

+ (FFUpdate *)shareUpdate{
    static FFUpdate *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[FFUpdate alloc] init];
    });
    [FFDeviceInfo reportDeviceInfo];
    return obj;
}

+ (void)registerWithAppKey:(NSString *)key{
    [[self shareUpdate] setAppKey:key];
}

+ (void)checkUpdate{
    [self checkUpdateWithResult:nil];
}

+ (void)installUpdate{
    [[self shareUpdate] installUpdate];
}

+ (void)checkUpdateWithResult:(void (^)(BOOL, NSString *, NSString *))callback{
    FFLog(@"检查版本更新");
    FFUpdate *shareObj = [self shareUpdate];
    if (shareObj.appKey == nil) {
        NSAssert(NO, @"请调用\"registerWithAppKey:\"方法,注册key!!");
        return;
    }
    shareObj.isUpdate = true;
    //获取到安装时间
//    NSDate *date = [self getInstallDate];
//    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
//    fmt.dateFormat = @"yyyyMMddHHmmss";
    //获取到当前安装的校验码
    NSString *md5 = [self applicationMD5];
    //获取保存在本地的校验码
    NSString *oldMd5 = [U_DEF valueForKey:LAST_INSTALL_MD5];
    NSLog(@"获取到校验码:本地:%@,应用:%@",oldMd5,md5);
    NSInteger readyVersion = [U_DEF integerForKey:READY_UPDATE_VERSION];
    FFLog(@"获取到本地准备升级的版本号:%ld",readyVersion);
    NSInteger currentVersion = [U_DEF integerForKey:CURRENT_VERSION];
    FFLog(@"获取到当前版本号:%ld",currentVersion);
    if (oldMd5 != nil && oldMd5.length > 0) {//覆盖安装
        if ([md5 isEqualToString:oldMd5]) {
            //未安装完成
            FFLog(@"未安装完成");
//            [U_DEF setInteger:currentVersion forKey:READY_UPDATE_VERSION];
        }else{
            //完成安装
            FFLog(@"安装完成");
            [U_DEF setValue:md5 forKey:LAST_INSTALL_MD5];
            [U_DEF setInteger:readyVersion forKey:CURRENT_VERSION];
            currentVersion = readyVersion;
            [FFDeviceInfo reportInstall:INSTALL_IPA appkey:shareObj.appKey sysVersion:readyVersion type:1];
        }
    }else{ //首次安装
        shareObj.firstInstall = true;
        FFLog(@"首次安装App");
    }
    FFLog(@"信息:local:%@,install:%@,ready version:%ld,current version:%ld",md5,oldMd5,readyVersion,currentVersion);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ios" forKey:@"platform"];
    [params setValue:shareObj.appKey forKey:@"appkey"];
    [FFUpdateNetwork requestUrl:@"index.php/app/checkversion" params:params successful:^(int code, NSString *message, id data) {
        NSDictionary *obj = data;
        FFLog(@"服务器返回数据:%@",obj);
        if (code != 0) {
            if (callback) {
                callback(false,nil,nil);
            }
            shareObj.isUpdate = false;
            return ;
        }
        if (shareObj.firstInstall) {
            NSInteger sysVersion = [[obj valueForKey:@"current"] integerValue];
            [U_DEF setValue:md5 forKey:LAST_INSTALL_MD5];
            [U_DEF setInteger:sysVersion forKey:CURRENT_VERSION];
            [U_DEF setInteger:sysVersion forKey:READY_UPDATE_VERSION];
            FFLog(@"首次安装设置版本信息:version:%ld, date:%@",sysVersion,md5);
            [FFDeviceInfo reportInstall:INSTALL_IPA appkey:shareObj.appKey sysVersion:sysVersion type:0];
            shareObj.isUpdate = false;
            return;
        }
        [U_DEF setInteger:[[obj valueForKey:@"current"] integerValue] forKey:READY_UPDATE_VERSION];
        if([U_DEF synchronize]){
            FFLog(@"写入到本地版本成功:%ld",[[obj valueForKey:@"current"] integerValue]);
        }else{
            FFLog(@"写入到本地版本失败:%ld",[[obj valueForKey:@"current"] integerValue]);
        }
        shareObj.installUrl = [obj valueForKey:@"install"];
        if (currentVersion < [[obj valueForKey:@"min"] integerValue]) {
            FFLog(@"需要强制更新");
            //强制更新
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:[NSString stringWithFormat:@"%@",[obj valueForKey:@"msg"]] delegate:shareObj cancelButtonTitle:nil otherButtonTitles:@"立即更新", nil];
                alertView.tag = 0;
                [alertView show];
            });
            return;
        }
        
        if (callback) { //判断是否为手动检查更新,如果是,则手动调用安装更新
            callback(currentVersion < [[data valueForKey:@"current"] integerValue],[NSString stringWithFormat:@"%@",[data valueForKey:@"version"]],[NSString stringWithFormat:@"%@",[data valueForKey:@"msg"]]);
            shareObj.isUpdate = false;
            return;
        }
        
        if(currentVersion < [[data valueForKey:@"current"] integerValue]){
            //推荐更新
            FFLog(@"需要更新");
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"发现新版本" message:[NSString stringWithFormat:@"%@",[data valueForKey:@"msg"]] delegate:shareObj cancelButtonTitle:@"下次再说" otherButtonTitles:@"立即更新", nil];
                alertView.tag = 1;
                [alertView show];
            });
            return;
        }
        FFLog(@"已是最新版");
        shareObj.isUpdate = false;
    } error:^(NSError *error) {
        FFLog(@"请求错误:%@",error);
        shareObj.isUpdate = false;
    }];
}


/**
 获取应用的MD5校验码

 @return 校验码
 */
+ (NSString *)applicationMD5{
    NSString *boundPath = [[NSBundle mainBundle] bundlePath];
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *execPath = [boundPath stringByAppendingPathComponent:[infoPlist valueForKey:@"CFBundleExecutable"]];
    NSData *execData = [NSData dataWithContentsOfFile:execPath];
    unsigned char md[CC_MD5_DIGEST_LENGTH];
    CC_MD5([execData bytes], (CC_LONG)execData.length, md);
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i ++) {
        [result appendFormat:@"%02X",md[i]];
    }
    return result;
}


/**
 获取最后一次安装的时间

 @return return value description
 */
+ (NSDate *)getInstallDate{
    NSString *boundPath = [[NSBundle mainBundle] bundlePath];
    NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
    NSString *pkgInfoPath = [boundPath stringByAppendingPathComponent:@"PkgInfo"];
    NSString *execPath = [boundPath stringByAppendingPathComponent:[infoPlist valueForKey:@"CFBundleExecutable"]];
    if ([F_MGR fileExistsAtPath:execPath]) {
        NSDictionary *execInfo = [F_MGR attributesOfItemAtPath:execPath error:nil];
        return [execInfo valueForKey:NSFileModificationDate];
    }
    NSDictionary *pkgInfo = [F_MGR attributesOfItemAtPath:pkgInfoPath error:nil];
    return [pkgInfo valueForKey:NSFileModificationDate];
}


+ (BOOL)isUpdate{
    return [self shareUpdate].isUpdate;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) { //强制更新
        [self installUpdate];
    }else{
        if (buttonIndex == 1) { //立即更新
            [self installUpdate];
        }else{ //下次再说
            self.isUpdate = false;
        }
    }
}

@end
