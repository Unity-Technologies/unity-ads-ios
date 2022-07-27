#import <Foundation/Foundation.h>
#import "UADSMetricCommonTags.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "USRVJsonStorage.h"
#import "UADSPrivacyStorage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSMetricCommonTagsProvider <NSObject>
- (UADSMetricCommonTags *) commonTags;
- (nullable NSDictionary *)commonInfo;
@end


@interface UADSMetricCommonTagsProviderBase : NSObject <UADSMetricCommonTagsProvider>

+ (instancetype)       newWithTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader
                           storageReader: (id<UADSJsonStorageReader>)storageReader
                           privacyReader: (id<UADSPrivacyResponseReader>)privacyReader;

@end

NS_ASSUME_NONNULL_END
