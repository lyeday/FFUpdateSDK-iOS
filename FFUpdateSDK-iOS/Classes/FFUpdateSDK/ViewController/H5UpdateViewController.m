//
//  H5UpdateViewController.m
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import "H5UpdateViewController.h"
#import "FFCordovaResourceUpdate.h"
#import "ZipArchive.h"
#import "FFNetwork.h"
#import "UIViewController+FFUpdate.h"

//FF_CORDOVA_RESOURCE_VERSION

@class CDVViewController;

@interface H5UpdateViewController ()<UIAlertViewDelegate>

/** 导航栏 */
@property (nonatomic,weak) UIView *navigationView;

/** 线 */
@property (nonatomic,weak) UIView *navLine;

/** 导航栏 */
@property (nonatomic,weak) UILabel *titleLab;

/** 进度标题 */
@property (nonatomic,weak) UILabel *progressTitleLab;

/** 当前进度 */
@property (nonatomic,weak) UILabel *progressLab;

/** 加载 */
@property (nonatomic,weak) UIImageView *updateImageView;

/** 更新进度 */
@property (nonatomic,strong) UIProgressView *progressView;

/** 更新内容 */
@property (nonatomic,weak) UILabel *updateMsgLab;

/** 是否为强制更新 */
@property (nonatomic,assign) BOOL isForce;

@end

@implementation H5UpdateViewController{
    NSString *_zipFilePath;
    NSString *_unzipPath;
    NSFileManager *_fm;
    UIViewController *_rootViewController;
}

- (void)viewDidLoad {
    _fm = [NSFileManager defaultManager];
    [super viewDidLoad];
    [self loadUpdateView];
    self.view.backgroundColor = [UIColor whiteColor];
    self.titleLab.text = @"正在更新";
    self.progressTitleLab.text = @"正在下载更新文件";
    self.progressView.progress = 0;
    self.progressLab.text = @"0%";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self downloadUpdate];
    });
}


- (void)resetApplicationRootViewController:(UIViewController *)rootViewController{
    _rootViewController = rootViewController;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"更新成功" message:nil delegate:self cancelButtonTitle:@"立即体验" otherButtonTitles:nil, nil];
    alertView.tag = 4;
    [alertView show];
}


/**
 更新失败
 */
- (void)updateFaild{
    NSInteger current = [[self.data valueForKey:@"current"] integerValue];
    NSInteger min = [[self.data valueForKey:@"min"] integerValue];
    if ([FFCordovaResourceUpdate currentHtmlVersion] < min || [FFCordovaResourceUpdate currentHtmlVersion]>current) { //强制更新
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"更新失败,请重试 !" message:nil delegate:self cancelButtonTitle:@"再试一次" otherButtonTitles:nil, nil];
        alertView.tag = 0;
        [alertView show];
        return ;
    }
    if ([FFCordovaResourceUpdate currentHtmlVersion] < current) { //推荐更新
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"更新失败" message:nil delegate:self cancelButtonTitle:@"下次更新" otherButtonTitles:@"再试一次", nil];
        alertView.tag = 1;
        [alertView show];
        return;
    }
    [self dismissViewControllerAnimated:true completion:nil];
}


/**
 更新成功
 */
- (void)updateComplete{
    NSInteger current = [[self.data valueForKey:@"current"] integerValue];
    NSString *index = [self.data valueForKey:@"index"];
    [[NSUserDefaults standardUserDefaults] setInteger:current forKey:@"FF_CORDOVA_RESOURCE_VERSION"];
    BOOL check = false;
    if (index.length > 0) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[_unzipPath stringByAppendingPathComponent:index]]) {
            check = true;
        }
    }
    if (!check) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"更新失败" message:@"入口文件未找到,请与开发者联系" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        alertView.tag = 3;
        [alertView show];
        return;
    }
    [_fm removeItemAtPath:[FFCordovaResourceUpdate wwwURL].path error:nil];
    [self copyFilePath:_unzipPath toPath:[FFCordovaResourceUpdate wwwURL].path];
    [FFCordovaResourceUpdate setStartPage:index];
    UIViewController *vc = (UIViewController *)[FFCordovaResourceUpdate mainViewController];
    Class clz = [vc class];
    if ([vc isKindOfClass:NSClassFromString(@"CDVViewController")]) {
        if (vc.navigationController == nil && vc.tabBarController == nil) {
            UIViewController *c_vc = [[clz alloc] init];
            [c_vc cordova_initCDVViewController];
            [self resetApplicationRootViewController:c_vc];
            return;
        }
    }
    
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"更新成功" message:@"请退出后重新打开软件" delegate:self cancelButtonTitle:@"立即退出" otherButtonTitles:nil, nil];
        alertView.tag = 2;
        [alertView show];
        return;
    }
}




/**
 解压更新
 */
- (void)unzipUpdate{
    _unzipPath = [[FFCordovaResourceUpdate zipTempURL].path stringByAppendingPathComponent:@"unzip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_unzipPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_unzipPath error:nil];
    }
    [SSZipArchive unzipFileAtPath:_zipFilePath toDestination:_unzipPath progressHandler:^(NSString * _Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat progress = entryNumber*1.0f/total;
            self.progressView.progress = progress;
            self.progressLab.text = [NSString stringWithFormat:@"%02d%%",(int)(progress*100.0)];
        });
    } completionHandler:^(NSString * _Nonnull path, BOOL succeeded, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (succeeded) {
                self.progressView.progress = 1;
                self.progressLab.text = @"100%";
                NSLog(@"更新成功:%@",path);
                [self updateComplete];
            }else{
                self.progressView.progress = 0;
                self.progressLab.text = @"0%";
                NSLog(@"更新失败");
                [self updateFaild];
            }
        });
    }];
}


/**
 下载更新
 */
- (void)downloadUpdate{
    self.progressTitleLab.text = @"正在下载更新";
    _zipFilePath = [[FFCordovaResourceUpdate zipTempURL].path stringByAppendingPathComponent:@"update.zip"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:_zipFilePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:_zipFilePath error:nil];
    }
    [FFNetwork downloadFileWithUrl:[NSString stringWithFormat:@"appWeb.php/app/downloadUpdate?id=%@",[self.data valueForKey:@"id"]] toLocationPath:_zipFilePath
                          progress:^(int64_t speedBytes, int64_t completeBytes, int64_t totalBytes) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  CGFloat downloadProgress = completeBytes*1.0f/totalBytes;
                                  self.progressView.progress = downloadProgress;
                                  self.progressLab.text = [NSString stringWithFormat:@"%02d%%",(int)(downloadProgress*100.0)];
                              });
                          } success:^(NSString *filePath) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  self.progressTitleLab.text = @"正在释放更新文件...";
                                  self.progressLab.text = @"0%";
                                  self.progressView.progress = 0;
                              });
                              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                  [self unzipUpdate];
                              });
                          } faild:^(NSError *error) {
                              dispatch_async(dispatch_get_main_queue(), ^{
                                  [self updateFaild];
                              });
                          }];
}


/**
 下载更新视图
 */
- (void)loadUpdateView{
    UIView *updateView = [[UIView alloc] init];
    [self.view addSubview:updateView];
    _updateView = updateView;
    
    UIView *navigationView = [[UIView alloc] init];
    navigationView.backgroundColor = [UIColor colorWithRed:0.992 green:0.992 blue:0.992 alpha:1.00];
    [self.updateView addSubview:navigationView];
    _navigationView = navigationView;
    
    UIView *navLine = [[UIView alloc] init];
    navLine.backgroundColor = [UIColor colorWithRed:0.749 green:0.749 blue:0.749 alpha:1.00];
    [_navigationView addSubview:navLine];
    _navLine = navLine;
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [_navigationView addSubview:titleLab];
    _titleLab = titleLab;
    
    UILabel *progressTitleLab = [[UILabel alloc] init];
    progressTitleLab.textColor = [UIColor grayColor];
    [self.updateView addSubview:progressTitleLab];
    _progressTitleLab = progressTitleLab;
    
    UILabel *progressLab = [[UILabel alloc] init];
    progressLab.textColor = [UIColor colorWithRed:0.129 green:0.592 blue:0.847 alpha:1.00];
    progressLab.text = @"00%";
    progressLab.textAlignment = NSTextAlignmentRight;
    progressLab.font = [UIFont systemFontOfSize:20];
    [self.updateView addSubview:progressLab];
    _progressLab = progressLab;
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    [self.updateView addSubview:progressView];
    _progressView = progressView;
    
    UIImageView *updateImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon.bundle/update"]];
    [self.updateView addSubview:updateImageView];
    _updateImageView = updateImageView;
    
    UILabel *updateMsgLab = [[UILabel alloc] init];
    updateMsgLab.textColor = [UIColor grayColor];
    updateMsgLab.font = [UIFont systemFontOfSize:15];
    updateMsgLab.numberOfLines = 0;
    [self.updateView addSubview:updateMsgLab];
    _updateMsgLab = updateMsgLab;
    
    
    NSAttributedString *updateTitles = [[NSAttributedString alloc] initWithString:@"更新内容:\n" attributes:@{NSFontAttributeName:self.updateMsgLab.font,NSForegroundColorAttributeName:[UIColor colorWithRed:0.129 green:0.592 blue:0.847 alpha:1.00]}];
    NSAttributedString *msgs = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",[self.data valueForKey:@"msg"]] attributes:@{NSFontAttributeName:self.updateMsgLab.font,NSForegroundColorAttributeName:[UIColor grayColor]}];
    NSMutableAttributedString *attrs = [[NSMutableAttributedString alloc] init];
    [attrs appendAttributedString:updateTitles];
    [attrs appendAttributedString:msgs];
    self.updateMsgLab.attributedText = attrs;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.updateView.frame = self.view.bounds;
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
    CGRect updateFrame = self.updateView.frame;
    _navigationView.frame = CGRectMake(0, 0, screenSize.width, 44+statusFrame.size.height);
    _navLine.frame = CGRectMake(0, _navigationView.frame.size.height-0.5, _navigationView.frame.size.width, 0.5);
    _titleLab.frame = CGRectMake(0, statusFrame.size.height, screenSize.width, 44);
    
    _updateImageView.frame = CGRectMake((self.updateView.frame.size.width-100)/2.0, self.updateView.frame.size.height * 0.25-50.0f, 100, 100);
    
    _progressView.frame = CGRectMake(0, 0, updateFrame.size.width*0.9f, 30);
    _progressView.center = self.updateView.center;
    
    _progressTitleLab.frame = CGRectMake(_progressView.frame.origin.x, _progressView.frame.origin.y-40, _progressView.frame.size.width-65, 40);
    
    _progressLab.frame = CGRectMake(CGRectGetMaxX(_progressView.frame)-65, _progressView.frame.origin.y-40, 60, 40);
    
    
    if (self.updateMsgLab.text.length > 0) {
        CGRect updateMsgFrame = CGRectMake(_progressView.frame.origin.x, CGRectGetMaxY(_progressView.frame) + 20, _progressView.frame.size.width, self.updateView.frame.size.height * 0.4f);
        CGSize msgSize = [self.updateMsgLab.text boundingRectWithSize:updateMsgFrame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.updateMsgLab.font} context:nil].size;
        updateMsgFrame.size = msgSize;
        _updateMsgLab.frame = updateMsgFrame;
    }
    
    [_updateView.layer removeAllAnimations];
    CABasicAnimation *imgAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    imgAnimation.fromValue = [NSNumber numberWithFloat: 0.0 ];
    imgAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    imgAnimation.duration = 8;
    imgAnimation.repeatCount = CGFLOAT_MAX;
    [_updateImageView.layer addAnimation:imgAnimation forKey:@"UPDATE_ANI"];
}


- (void)copyFilePath:(NSString *)path toPath:(NSString *)toPath{
    
    [_fm createDirectoryAtPath:toPath withIntermediateDirectories:true attributes:nil error:nil];
    NSArray<NSString *> *list = [_fm contentsOfDirectoryAtPath:path error:nil];
    for (int i = 0; i < list.count; i ++) {
        NSString *name = [list objectAtIndex:i];
        if ([name isEqualToString:@"__MACOSX"]) {
            continue ;
        }
        NSString *subPath = [path stringByAppendingPathComponent:name];
        BOOL isDir = false;
        [_fm fileExistsAtPath:subPath isDirectory:&isDir];
        if (isDir) {
            [self copyFilePath:subPath toPath:[toPath stringByAppendingPathComponent:name]];
        }else{
            NSString *to = [toPath stringByAppendingPathComponent:name];
            if ([_fm fileExistsAtPath:to]) {
                [_fm removeItemAtPath:to error:nil];
            }
            [_fm copyItemAtPath:subPath toPath:to error:nil];
        }
        
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 0) {
        [self downloadUpdate];
    }else if(alertView.tag == 1){
        if (buttonIndex == 0) { //下次再说
            [self dismissViewControllerAnimated:true completion:nil];
        }else{
            [self downloadUpdate];
        }
    }else if(alertView.tag == 2){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    }else if(alertView.tag == 3){
       [self dismissViewControllerAnimated:true completion:nil];
    }else if(alertView.tag == 4){
        [self dismissViewControllerAnimated:true completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].keyWindow.rootViewController = _rootViewController;
            });
        }];
    }
}



@end
