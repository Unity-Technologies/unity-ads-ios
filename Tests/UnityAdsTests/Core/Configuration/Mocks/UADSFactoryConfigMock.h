#import <Foundation/Foundation.h>
#import "UADSClientConfig.h"

NS_ASSUME_NONNULL_BEGIN


@interface UADSFactoryConfigMock : NSObject<UADSClientConfig>
@property (nonatomic) BOOL isSwiftInitEnabled;

@property (nonatomic) NSString *gameID;
@property (nonatomic) NSString *sdkVersionName;
@property (nonatomic) NSNumber *sdkVersion;
@end

NS_ASSUME_NONNULL_END
