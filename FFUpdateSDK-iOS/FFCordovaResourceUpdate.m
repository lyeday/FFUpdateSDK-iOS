//
//  CordovaResourceUpdate.m
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import "FFCordovaResourceUpdate.h"
#import "FFUpdateNetwork.h"
#import "H5UpdateViewController.h"
#import "FFUpdate.h"
#import "FFDeviceInfo.h"

#define KEY_CORDOVA_RESOURCE_VERSION @"FF_CORDOVA_RESOURCE_VERSION"
#define KEY_CORDOVA_RESOURCE_INDEX   @"FF_CORDOVA_RESOURCE_INDEX"

#define U_DEF [NSUserDefaults standardUserDefaults]
#define F_MGR [NSFileManager defaultManager]

@interface FFCordovaResourceUpdate()<UIAlertViewDelegate>

/** 资源加载目录 */
@property (nonatomic,copy) NSString *wwwPath;

/** appkey */
@property (nonatomic,copy) NSString *appKey;

/** main view controller */
@property (nonatomic,strong) UIViewController *viewController;

/** 更新数据 */
@property (nonatomic,strong) NSDictionary *data;

@end

@implementation FFCordovaResourceUpdate


- (void)gotoUpdate{
    dispatch_async(dispatch_get_main_queue(), ^{
        H5UpdateViewController *updateVC = [[H5UpdateViewController alloc] init];
        //    UIViewController *viewController = (UIViewController *)vc;
        //    id webViewEngine = [viewController valueForKey:@"webViewEngine"];
        updateVC.data = self.data;
        [self.viewController presentViewController:updateVC animated:true completion:nil];
    });
}

+ (FFCordovaResourceUpdate *)shareUpdate{
    static FFCordovaResourceUpdate *obj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[FFCordovaResourceUpdate alloc] init];
    });
    [FFDeviceInfo reportDeviceInfo];
    return obj;
}

+ (void)registerWithAppKey:(NSString *)key{
    [self shareUpdate].appKey = key;
    NSLog(@"register App Key:%@",key);
}

+ (void)checkUpdateWithViewController:(UIViewController *)vc{
    if ([FFUpdate isUpdate]) {
        [self performSelector:@selector(checkUpdateWithViewController:) withObject:vc afterDelay:10];
        return;
    }
    
    [[self shareUpdate] setViewController:(UIViewController *)vc];
    NSInteger appVersion = [U_DEF integerForKey:@"__FFUPDATE_CURRENT_VERSION"];
    NSInteger localHtmlVersion = [U_DEF integerForKey:KEY_CORDOVA_RESOURCE_VERSION];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:@"ios" forKey:@"platform"];
    [params setValue:@(appVersion) forKey:@"version"];
    [params setValue:[self shareUpdate].appKey forKey:@"appkey"];
    [FFUpdateNetwork requestUrl:@"index.php/app/checkhtml" params:params successful:^(int code, NSString *message, id data) {
        if (code == 0) {
            [[self shareUpdate] setData:data];
            NSInteger current = [[data valueForKey:@"current"] integerValue];
            NSInteger min = [[data valueForKey:@"min"] integerValue];
            NSString *msg = [data valueForKey:@"msg"];
            if (localHtmlVersion < min || localHtmlVersion > current) { //强制更新
                [[self shareUpdate] gotoUpdate];
                return ;
            }
            if (localHtmlVersion < current) { //推荐更新
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"应用包更新" message:[NSString stringWithFormat:@"%@",msg] delegate:[self shareUpdate] cancelButtonTitle:@"下次更新" otherButtonTitles:@"立即更新", nil];
                    [alertView show];
                });
                return;
            }
        }
    } error:^(NSError *error) {
        
    }];
}

+ (NSInteger)currentHtmlVersion{
    return [U_DEF integerForKey:KEY_CORDOVA_RESOURCE_VERSION];
}

+ (void)setStartPage:(NSString *)index{
    [U_DEF setValue:index forKey:KEY_CORDOVA_RESOURCE_INDEX];
    [U_DEF synchronize];
}

+ (NSString *)startPage{
    return [U_DEF valueForKey:KEY_CORDOVA_RESOURCE_INDEX];
}

+ (void)setCurrentVersion:(NSInteger)currentVersion{
    NSInteger localHtmlVersion = [U_DEF integerForKey:KEY_CORDOVA_RESOURCE_VERSION];
    if (localHtmlVersion < currentVersion) {
        [U_DEF setInteger:currentVersion forKey:KEY_CORDOVA_RESOURCE_VERSION];
        [U_DEF setObject:nil forKey:KEY_CORDOVA_RESOURCE_INDEX];
        [[NSFileManager defaultManager] removeItemAtURL:[self wwwURL] error:nil];
    }
    [U_DEF synchronize];
}


+ (NSURL *)zipTempURL{
    static NSURL *url = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"ZIPTEMP"];
        if (![F_MGR fileExistsAtPath:path]) {
            [F_MGR createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil];
        }
        url = [NSURL fileURLWithPath:path];
    });
    return url;
}

+ (NSURL *)wwwURL{
    static NSURL *url = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject stringByAppendingPathComponent:@"www"];
        if (![F_MGR fileExistsAtPath:path]) {
            [F_MGR createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil];
        }
        url = [NSURL fileURLWithPath:path];
    });
    return url;
}

+ (UIViewController *)mainViewController{
    return [self shareUpdate].viewController;
}

+ (NSString *)appkey{
    return [self shareUpdate].appKey;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) { //下次再说
        
    }else{ //立即更新
        [self gotoUpdate];
    }
}


@end
