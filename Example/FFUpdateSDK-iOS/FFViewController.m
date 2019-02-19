//
//  FFViewController.m
//  FFUpdateSDK-iOS
//
//  Created by voisen on 01/15/2019.
//  Copyright (c) 2019 voisen. All rights reserved.
//

#import "FFViewController.h"
#import <FFUpdate.h>
#import <FFCordovaResourceUpdate.h>
#import <CommonCrypto/CommonDigest.h>

@interface FFViewController ()

/** 视图 */
@property (nonatomic,weak) UILabel *msgLab;

@end

@implementation FFViewController{
    NSFileManager *_fm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)md5{
    self.msgLab.text = [NSString stringWithFormat:@"MD5:%@",[self applicationMD5]];
}


- (NSString *)applicationMD5{
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

- (void)loadView{
    [super loadView];
    UILabel *msgLab = [[UILabel alloc] init];
    msgLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:msgLab];
    _msgLab = msgLab;
    
    msgLab.frame = CGRectMake(0, 20, self.view.frame.size.width, 200);
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"获取校验值" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(md5) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    btn.frame = CGRectMake(0, CGRectGetMaxY(msgLab.frame)+50, self.view.frame.size.width, 50);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
