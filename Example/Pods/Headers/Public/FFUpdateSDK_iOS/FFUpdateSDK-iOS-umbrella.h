#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FFCordovaResourceUpdate.h"
#import "FFUpdate.h"
#import "UIViewController+FFUpdate.h"

FOUNDATION_EXPORT double FFUpdateSDK_iOSVersionNumber;
FOUNDATION_EXPORT const unsigned char FFUpdateSDK_iOSVersionString[];

