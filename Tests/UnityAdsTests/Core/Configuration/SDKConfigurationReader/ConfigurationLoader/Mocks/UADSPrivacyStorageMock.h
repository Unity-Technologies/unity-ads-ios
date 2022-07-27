#import <Foundation/Foundation.h>
#import "UADSPrivacyStorage.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSPrivacyStorageMock : NSObject<UADSPrivacyResponseSaver, UADSPrivacyResponseReader>
@property (nonatomic, strong) NSArray<UADSInitializationResponse *> *responses;
@property (nonatomic, assign) UADSPrivacyResponseState expectedState;
@end

NS_ASSUME_NONNULL_END
