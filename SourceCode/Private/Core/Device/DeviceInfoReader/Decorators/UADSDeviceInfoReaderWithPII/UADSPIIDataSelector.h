#import <Foundation/Foundation.h>
#import "UADSPIIDecisionData.h"
#import "USRVJsonStorage.h"
#import "UADSPIITrackingStatusReader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSPrivacyConfig <NSObject>
- (BOOL)                   isForcedUpdatePIIEnabled;
- (BOOL)                   isPrivacyRequestEnabled;
@end

@protocol UADSPIIDataSelector <NSObject>
- (UADSPIIDecisionData *)  whatToDoWithPII;
@end

@interface UADSPIIDataSelectorBase : NSObject<UADSPIIDataSelector>
+ (id<UADSPIIDataSelector>)newWithJsonStorage: (id<UADSJsonStorageReader>)jsonStorage
                              andStatusReader: (id<UADSPIITrackingStatusReader>)statusReader
                                 andPIIConfig: (id<UADSPrivacyConfig>)piiConfig;
@end

NS_ASSUME_NONNULL_END
