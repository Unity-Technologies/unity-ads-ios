#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, UnityAdsTokenStorageEvent) {
    kUnityAdsTokenStorageQueueEmpty,
    kUnityAdsTokenStorageAccessToken
};

NSString * UADSNSStringFromTokenStorageEvent(UnityAdsTokenStorageEvent);
