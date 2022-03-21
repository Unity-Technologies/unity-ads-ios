#import "UADSConfigurationLoaderMock.h"

@implementation UADSConfigurationLoaderMock

- (instancetype)init
{
    self = [super init];

    if (self) {
        self.loadCallCount = 0;
    }

    return self;
}

- (void)loadConfigurationWithSuccess: (UADSConfigurationCompletion NS_NOESCAPE)success andErrorCompletion: (UADSErrorCompletion NS_NOESCAPE)error {
    _loadCallCount += 1;

    if (self.expectedError) {
        error(self.expectedError);
        return;
    }

    if (self.expectedConfig) {
        success(self.expectedConfig);
        return;
    }

    assert(0);
}

@end
