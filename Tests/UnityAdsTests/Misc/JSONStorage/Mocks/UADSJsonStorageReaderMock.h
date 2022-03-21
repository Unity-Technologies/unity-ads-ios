#import <UIKit/UIKit.h>
#import "USRVJsonStorage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSJsonStorageReaderMock : NSObject<UADSJsonStorageContentsReader, UADSJsonStorageReader>
@property (nonatomic, strong) id<UADSJsonStorageContentsReader, UADSJsonStorageReader> original;
@property (nonatomic, strong) NSDictionary *expectedContent;
@property (nonatomic, assign) NSInteger getContentCount;
@property (nonatomic, strong) NSArray<NSString *> *requestedKeys;
@end

NS_ASSUME_NONNULL_END
