#import <Foundation/Foundation.h>
#import "UADSPIIDecisionData.h"
#import "USRVJsonStorage.h"
#import "UADSPIITrackingStatusReader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSPIIDataSelectorConfig <NSObject>
- (BOOL)                   isForcedUpdatePIIEnabled;
@end

@protocol UADSPIIDataSelector <NSObject>
- (UADSPIIDecisionData *)  whatToDoWithPII;
@end

@interface UADSPIIDataSelectorBase : NSObject<UADSPIIDataSelector>
+ (id<UADSPIIDataSelector>)newWithJsonStorage: (id<UADSJsonStorageReader>)jsonStorage
                              andStatusReader: (id<UADSPIITrackingStatusReader>)statusReader
                                 andPIIConfig: (id<UADSPIIDataSelectorConfig>)piiConfig;
@end

NS_ASSUME_NONNULL_END
