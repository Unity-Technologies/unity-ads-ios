#import "UADSPIITrackingStatusReaderMock.h"
#import "UADSTools.h"
@implementation UADSPIITrackingStatusReaderMock

- (instancetype)init {
    SUPER_INIT;
    self.userBehavioralCount = 0;
    return self;
}

- (UADSPrivacyMode)privacyMode {
    return self.expectedMode;
}

- (BOOL)userNonBehavioralFlag {
    _userBehavioralCount += 1;
    return self.expectedUserBehaviouralFlag ? : false;
}

@end
