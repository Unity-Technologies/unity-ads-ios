#import "UADSPrivacyLoaderMock.h"


@implementation UADSPrivacyLoaderMock

- (void)loadPrivacyWithSuccess: (nonnull UADSPrivacyCompletion)success
            andErrorCompletion: (nonnull UADSErrorCompletion)errorCompletion {
    _loadCallCount += 1;

    if (self.expectedError) {
        errorCompletion(self.expectedError);
        return;
    }

    if (self.expectedResponse) {
        success(self.expectedResponse);
        return;
    }

    assert(0);
}

@end
