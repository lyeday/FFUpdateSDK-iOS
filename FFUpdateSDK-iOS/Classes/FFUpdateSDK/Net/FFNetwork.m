//
//  FFNetwork.m
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import "FFNetwork.h"
#import <objc/runtime.h>

//#define BASE_URL @"https://192.168.1.188/apps/"
#define BASE_URL @"https://www.jssgwl.com/apps/"

@interface FFNetwork()<NSURLSessionDelegate,NSURLSessionDownloadDelegate>

/** 请求 */
@property (nonatomic,strong) NSURLSession *session;

@end

@implementation FFNetwork

+ (FFNetwork *)shareNetwork{
    static FFNetwork *shareObj = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObj = [[FFNetwork alloc] init];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        shareObj.session = [NSURLSession sessionWithConfiguration:config delegate:shareObj delegateQueue:[NSOperationQueue new]];
    });
    return shareObj;
}

+ (NSURLSession *)shareUrlSession{
    return [[self shareNetwork] session];
}


/**
 网络请求公共方法
 
 @param url 请求的url
 @param para 参数
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
+ (void)requestUrl:(NSString *)url params:(NSDictionary *)para successful:(void(^)(int code,NSString *message,id data))successCallback error:(void(^)(NSError *error))errorCallback{
    NSString *requestUrl = [BASE_URL stringByAppendingString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:30];
    NSMutableString *bodyParams = [NSMutableString string];
    __block BOOL first = true;
    [para enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (!first) {
            [bodyParams appendString:@"&"];
        }
        [bodyParams appendFormat:@"%@=%@",key,obj];
        first = false;
    }];
    [request setHTTPBody:[bodyParams dataUsingEncoding:NSUTF8StringEncoding]];
    
    [[[self shareUrlSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (errorCallback) {
                errorCallback(error);
            }
        }else{
            NSDictionary *dataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            int code = [[dataDict valueForKey:@"code"] intValue];
            NSString *msg = [dataDict valueForKey:@"message"];
            id data = [dataDict valueForKey:@"data"];
            if (successCallback) {
                successCallback(code,msg,data);
            }
        }
    }] resume];
}


+ (void)downloadFileWithUrl:(NSString *)url
             toLocationPath:(NSString *)path
                   progress:(DownloadProgressCallback)progressCallback
                    success:(DownloadSuccessCallback)successCallback
                    faild:(DownloadFaildCallback)faildCallback{
    NSString *requestUrl = [BASE_URL stringByAppendingString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:requestUrl]];
    request.timeoutInterval = 30;
    NSURLSessionDownloadTask *task = [[self shareUrlSession] downloadTaskWithRequest:request];
    objc_setAssociatedObject(task, @"f_path", path, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(task, @"p_callback", progressCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(task, @"s_callback", successCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(task, @"e_callback", faildCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [task resume];
}


#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if ([task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        NSHTTPURLResponse *resp = (NSHTTPURLResponse *)task.response;
        NSString *toPath = objc_getAssociatedObject(task, @"f_path");
        DownloadSuccessCallback successCallback = objc_getAssociatedObject(task, @"s_callback");
        DownloadFaildCallback faildCallback = objc_getAssociatedObject(task, @"e_callback");
        if (error || resp.statusCode != 200) {
            faildCallback(error);
        }else{
            successCallback(toPath);
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)downloadTask.response;
    if (resp.statusCode != 200) {
        return;
    }
    NSString *toPath = objc_getAssociatedObject(downloadTask, @"f_path");
    [[NSFileManager defaultManager] copyItemAtPath:location.path toPath:toPath error:nil];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)downloadTask.response;
    if (resp.statusCode != 200) {
        return;
    }
    DownloadProgressCallback progress = objc_getAssociatedObject(downloadTask, @"p_callback");
    progress(bytesWritten,totalBytesWritten,totalBytesExpectedToWrite);
}


#pragma mark - NSURLSessionDelegate


- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(NSURLSessionAuthChallengeUseCredential,credential);
}

@end
