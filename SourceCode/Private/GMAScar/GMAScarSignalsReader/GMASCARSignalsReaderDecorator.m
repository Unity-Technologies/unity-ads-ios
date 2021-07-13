#import "UADSTools.h"
#import "GMASCARSignalsReaderDecorator.h"
#import "NSError+UADSError.h"

@interface GMASCARSignalsReaderDecorator ()
@property (strong, nonatomic) id<GMASCARSignalsReader> signalService;
@end

@implementation GMASCARSignalsReaderDecorator
+ (instancetype)newWithSignalService: (id<GMASCARSignalsReader>)signalService {
    return [[self alloc] initWithSignalService: signalService];
}

- (instancetype)initWithSignalService: (id<GMASCARSignalsReader>)signalService {
    SUPER_INIT;
    self.signalService = signalService;
    return self;
}

- (void)getSCARSignalsUsingInterstitialList: (nonnull NSArray *)interstitialList
                            andRewardedList: (nonnull NSArray *)rewardedList
                                 completion: (nonnull UADSGMAEncodedSignalsCompletion *)completion {
    __weak typeof(self) weakSelf = self;
    UADSGMAScarSignalsCompletion *scarCompletion = [UADSGMAScarSignalsCompletion newWithSuccess: ^(UADSSCARSignals *_Nullable signals) {
        NSError *error;
        NSString *encodedString = [weakSelf encodeSignals: signals
                                                    error: &error];

        if (error) {
            [completion error: error];
        } else {
            [completion success: encodedString];
        }
    }
                                                                                       andError: ^(id<UADSError> _Nonnull error) {
                                                                                           [completion error: error];
                                                                                       }];

    [_signalService getSCARSignalsUsingInterstitialList: interstitialList
                                        andRewardedList: rewardedList
                                             completion: scarCompletion];
}

- (NSString *)encodeSignals: (UADSSCARSignals *)signals
                      error: (id<UADSError> *)error {
    if (signals.allKeys.count == 0) {
        return @"";
    }

    NSError *returnedError;
    NSData *jsonMap = [NSJSONSerialization dataWithJSONObject: signals
                                                      options: NSJSONWritingPrettyPrinted
                                                        error: &returnedError];

    if (returnedError) {
        return nil;
    }

    NSString *jsonString;

    if (jsonMap) {
        jsonString = [[NSString alloc] initWithData: jsonMap
                                           encoding: NSUTF8StringEncoding];
    }

    return jsonString;
}

@end
