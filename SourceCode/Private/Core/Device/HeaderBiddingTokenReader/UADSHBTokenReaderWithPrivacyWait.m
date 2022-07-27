#import "UADSHBTokenReaderWithPrivacyWait.h"

@interface UADSHBTokenReaderWithPrivacyWait ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader>original;
@property (nonatomic, strong) id<UADSPrivacyResponseReader, UADSPrivacyResponseSubject>subject;
@property (nonatomic, assign) NSInteger timeoutInSeconds;
@end

@implementation UADSHBTokenReaderWithPrivacyWait

+ (instancetype)newWithOriginal: (id<UADSHeaderBiddingAsyncTokenReader>)original
              andPrivacySubject: (id<UADSPrivacyResponseSubject, UADSPrivacyResponseReader>)subject
                        timeout: (NSInteger)timeoutInSeconds {
    UADSHBTokenReaderWithPrivacyWait *decorator = [UADSHBTokenReaderWithPrivacyWait new];

    decorator.original = original;
    decorator.subject = subject;
    decorator.timeoutInSeconds = timeoutInSeconds;
    return decorator;
}

- (void)getToken: (UADSHeaderBiddingTokenCompletion)completion {
    if (_subject.responseState != kUADSPrivacyResponseUnknown) {
        [self callOriginalGetToken: completion];
        return;
    }

    __weak typeof(self) weakSelf = self;

    [_subject subscribeWithTimeout: _timeoutInSeconds
                       forObserver: ^(UADSInitializationResponse *_Nonnull response) {
                           [weakSelf callOriginalGetToken: completion];
                       }
                           timeout:^{
                               [weakSelf callOriginalGetToken: completion];
                           }];
}

- (void)callOriginalGetToken: (UADSHeaderBiddingTokenCompletion)completion {
    [_original getToken: completion];
}

@end
