

typedef NS_ENUM(NSInteger, UnityAdsStorageType) {
    kUnityAdsStorageTypePublic = 1,
    kUnityAdsStorageTypePrivate = 2
};

@interface UADSStorage : NSObject

@property (nonatomic, assign) NSString *targetFileName;
@property (nonatomic, assign) UnityAdsStorageType type;
@property (nonatomic, strong) NSMutableDictionary *storageContents;

- (instancetype)initWithLocation:(NSString *)fileLocation type:(UnityAdsStorageType)type;
- (BOOL)setValue:(id)value forKey:(NSString *)key;
- (id)getValueForKey:(NSString *)key;
- (BOOL)deleteKey:(NSString *)key;
- (NSArray *)getKeys:(NSString *)key recursive:(BOOL)recursive;
- (void)sendEvent:(NSString *)eventType values:(NSDictionary *)values;

// FILE HANDLING
- (void)initStorage;
- (BOOL)readStorage;
- (BOOL)writeStorage;
- (BOOL)storageFileExists;
- (BOOL)clearStorage;
- (void)clearData;
- (BOOL)hasData;

@end