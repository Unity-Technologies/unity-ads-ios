#import "UADSPrivacyStorage.h"
#import "UADSGenericMediator.h"

NSString * uads_privacyResponseStateToString(UADSPrivacyResponseState state) {
    switch (state) {
        case kUADSPrivacyResponseUnknown:
            return @"unknown";

        case kUADSPrivacyResponseAllowed:
            return @"allowed";

        case kUADSPrivacyResponseDenied:
            return @"denied";
    }
}

@interface UADSPrivacyStorage ()
@property (nonatomic, strong) UADSInitializationResponse *response;
@property (nonatomic, strong) UADSGenericMediator<UADSInitializationResponse *> *mediator;
@end

@implementation UADSPrivacyStorage

- (instancetype)init {
    SUPER_INIT;
    self.mediator = [UADSGenericMediator new];
    return self;
}

- (void)saveResponse: (nonnull UADSInitializationResponse *)response {
    @synchronized (self) {
        self.response = response;
    }
    [self.mediator notifyObserversWithObjectAndRemove: response];
}

- (UADSPrivacyResponseState)responseState {
    if (!self.response) {
        return kUADSPrivacyResponseUnknown;
    }

    return self.response.allowTracking ? kUADSPrivacyResponseAllowed : kUADSPrivacyResponseDenied;
}

- (void)subscribe: (nonnull UADSPrivacyResponseObserver)observer {
    [self.mediator subscribe: observer];
}

- (void)subscribeWithTimeout: (NSInteger)timeInSeconds
                 forObserver: (nonnull UADSPrivacyResponseObserver)observer
                     timeout: (UADSVoidClosure)timeout {
    [self.mediator subscribeWithTimeout: timeInSeconds
                            forObserver: observer
                             andTimeout: timeout];
}

@end
