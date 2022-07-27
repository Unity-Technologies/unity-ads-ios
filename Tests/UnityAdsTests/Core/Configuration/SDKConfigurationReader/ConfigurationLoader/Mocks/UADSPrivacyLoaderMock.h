#import <Foundation/Foundation.h>
#import "UADSPrivacyLoader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSPrivacyLoaderMock : NSObject<UADSPrivacyLoader>
@property (nonatomic, strong) UADSInitializationResponse *_Nullable expectedResponse;
@property (nonatomic, strong) id<UADSError> __nullable expectedError;
@property (nonatomic, assign) int loadCallCount;

@end

NS_ASSUME_NONNULL_END
