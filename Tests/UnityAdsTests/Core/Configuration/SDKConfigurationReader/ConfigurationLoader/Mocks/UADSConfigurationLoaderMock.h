#import <Foundation/Foundation.h>
#import "UADSConfigurationLoader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationLoaderMock : NSObject<UADSConfigurationLoader>
@property (nonatomic, strong) USRVConfiguration *_Nullable expectedConfig;
@property (nonatomic, strong) id<UADSError> __nullable expectedError;
@property (nonatomic, assign) int loadCallCount;
@end

NS_ASSUME_NONNULL_END
