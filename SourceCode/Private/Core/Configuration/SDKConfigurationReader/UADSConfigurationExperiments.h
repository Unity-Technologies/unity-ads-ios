#import <Foundation/Foundation.h>
#import "UADSConfigurationRequestFactoryConfig.h"
#import "UADSPIIDataSelector.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationExperiments : NSObject
@property (readonly) NSDictionary<NSString *, NSString *> *json;
+ (instancetype)newWithJSON: (NSDictionary<NSString *, NSString *> *)json;
- (BOOL)        isTwoStageInitializationEnabled;
- (BOOL)        isPOSTMethodInConfigRequestEnabled;
- (BOOL)        isForwardExperimentsToWebViewEnabled;
- (BOOL)        isForcedUpdatePIIEnabled;
- (BOOL)        isHeaderBiddingTokenGenerationEnabled;
@end

NS_ASSUME_NONNULL_END
