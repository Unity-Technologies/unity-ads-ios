#import <Foundation/Foundation.h>
#import <USRVJsonStorage.h>

NS_ASSUME_NONNULL_BEGIN

@interface USRVJsonStorageAggregator : NSObject<UADSJsonStorageContentsReader, UADSJsonStorageReader>
+ (instancetype)defaultAggregator;

+ (instancetype)newWithReaders: (NSArray<id<UADSJsonStorageContentsReader> > *)readers;
@end

NS_ASSUME_NONNULL_END
