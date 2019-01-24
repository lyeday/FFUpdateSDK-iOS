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

@interface FFViewController ()

@end

@implementation FFViewController{
    NSFileManager *_fm;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [FFUpdate registerWithAppKey:@"kYvTNZmzD1kSzlSiKVmRuR8sU2U9vs5j"];
    [FFUpdate checkUpdate];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
