#import "USRVStorage.h"

@interface USRVStorageManager : NSObject

+ (BOOL)init;
+ (void)initStorage:(UnityServicesStorageType)storageType;
+ (USRVStorage *)getStorage:(UnityServicesStorageType)storageType;
+ (BOOL)hasStorage:(UnityServicesStorageType)storageType;
+ (void)addStorageLocation:(NSString *)location forStorageType:(UnityServicesStorageType)storageType;
+ (void)removeStorage:(UnityServicesStorageType)storageType;

@end
