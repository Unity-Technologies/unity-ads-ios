#import "UADSPrivacyStorageMock.h"

@implementation UADSPrivacyStorageMock
- (instancetype)init
{
    self = [super init];

    if (self) {
        self.responses = [NSArray new];
        self.shouldSendUserNonBehavioral = false;
    }

    return self;
}

- (void)saveResponse: (UADSInitializationResponse *)response {
    _responses = [_responses arrayByAddingObjectsFromArray: @[response]];
}

- (UADSPrivacyResponseState)responseState {
    return self.expectedState;
}

@end
