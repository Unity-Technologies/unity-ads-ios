#import "UADSJsonStorage.h"

typedef NS_ENUM(NSInteger, UnityAdsStorageType) {
    kUnityAdsStorageTypePublic = 1,
    kUnityAdsStorageTypePrivate = 2
};

@interface UADSStorage : UADSJsonStorage

@property (nonatomic, assign) NSString *targetFileName;
@property (nonatomic, assign) UnityAdsStorageType type;

- (instancetype)initWithLocation:(NSString *)fileLocation type:(UnityAdsStorageType)type;
- (void)sendEvent:(NSString *)eventType values:(NSDictionary *)values;

// FILE HANDLING
- (void)initStorage;
- (BOOL)readStorage;
- (BOOL)writeStorage;
- (BOOL)storageFileExists;
- (BOOL)clearStorage;

@end
