#import "UADSStorage.h"

@interface UADSStorageManager : NSObject

+ (BOOL)init;
+ (void)initStorage:(UnityAdsStorageType)storageType;
+ (UADSStorage *)getStorage:(UnityAdsStorageType)storageType;
+ (BOOL)hasStorage:(UnityAdsStorageType)storageType;
+ (void)addStorageLocation:(NSString *)location forStorageType:(UnityAdsStorageType)storageType;
+ (void)removeStorage:(UnityAdsStorageType)storageType;

@end