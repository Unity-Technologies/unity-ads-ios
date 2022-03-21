#import <Foundation/Foundation.h>
#import "USRVJsonStorage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSDictionaryKeysBlockList <NSObject>

- (NSArray<NSString *> *)          keysToSkip;

@end

@interface UADSDeviceInfoExcludeFieldsProvider : NSObject<UADSDictionaryKeysBlockList>;

+ (id<UADSDictionaryKeysBlockList>)defaultProvider;

+ (id<UADSDictionaryKeysBlockList>)newWithJSONStorage: (id<UADSJsonStorageReader>)jsonStorage;

@end

NS_ASSUME_NONNULL_END
