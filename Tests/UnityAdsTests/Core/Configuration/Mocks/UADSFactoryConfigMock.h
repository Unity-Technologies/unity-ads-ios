#import <Foundation/Foundation.h>
#import "UADSPIIDataSelector.h"
#import "UADSClientConfig.h"

NS_ASSUME_NONNULL_BEGIN


@interface UADSFactoryConfigMock : NSObject<UADSClientConfig, UADSPrivacyConfig>
@property (nonatomic) BOOL isTwoStageInitializationEnabled;
@property (nonatomic) BOOL isPOSTMethodInConfigRequestEnabled;
@property (nonatomic) BOOL isForcedUpdatePIIEnabled;
@property (nonatomic) BOOL isPrivacyRequestEnabled;
@property (nonatomic) BOOL isSwiftInitEnabled;

@property (nonatomic) NSString *gameID;
@property (nonatomic) NSString *sdkVersionName;
@property (nonatomic) NSNumber *sdkVersion;
@end

NS_ASSUME_NONNULL_END
