#import <Foundation/Foundation.h>
#import "UADSPrivacyStorage.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSPrivacyStorageMock : NSObject<UADSPrivacyResponseSaver, UADSPrivacyResponseReader, UADSPrivacyResponseSubject>
@property (nonatomic, strong) NSArray<UADSInitializationResponse *> *responses;
@property (nonatomic, assign) UADSPrivacyResponseState expectedState;
@property (nonatomic) BOOL shouldSendUserNonBehavioral;
@end

NS_ASSUME_NONNULL_END
