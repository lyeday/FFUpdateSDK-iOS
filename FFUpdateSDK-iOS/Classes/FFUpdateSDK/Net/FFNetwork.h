//
//  FFNetwork.h
//  FFUpdateSDK
//
//  Created by wuzhicheng on 2019/1/7.
//  Copyright © 2019年 wuzhicheng. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^DownloadProgressCallback)(int64_t speedBytes,int64_t completeBytes,int64_t totalBytes);
typedef void(^DownloadSuccessCallback)(NSString *filePath);
typedef void(^DownloadFaildCallback)(NSError *error);

@interface FFNetwork : NSObject

/**
 网络请求公共方法
 
 @param url 请求的url
 @param para 参数
 @param successCallback 成功回调
 @param errorCallback 失败回调
 */
+ (void)requestUrl:(NSString *)url params:(NSDictionary *)para successful:(void(^)(int code,NSString *message,id data))successCallback error:(void(^)(NSError *error))errorCallback;


+ (void)downloadFileWithUrl:(NSString *)url
             toLocationPath:(NSString *)path
                   progress:(DownloadProgressCallback)progressCallback
                    success:(DownloadSuccessCallback)successCallback
                      faild:(DownloadFaildCallback)faildCallback;
@end
