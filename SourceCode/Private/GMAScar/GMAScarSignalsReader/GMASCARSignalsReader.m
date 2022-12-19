
#import "GMASCARSignalsReader.h"

typedef void (^ReturnErrorCompletion)(id<UADSError>);
typedef NSMutableDictionary<NSString *, NSString *> UADSMutableScarSignals;
@interface GMABaseSCARSignalsReader ()
@property (strong, nonatomic) id<GMASignalService> signalService;
@property (strong, nonatomic) dispatch_queue_t syncQueue;
@end

@implementation GMABaseSCARSignalsReader

+ (instancetype)newWithSignalService: (id<GMASignalService>)signalService {
    return [[self alloc] initWithSignalService: signalService];
}

- (instancetype)initWithSignalService: (id<GMASignalService>)signalService {
    SUPER_INIT;
    self.signalService = signalService;
    self.syncQueue = dispatch_queue_create("GMABaseScarSignalsReader.Sync.Queue", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)getSCARSignalsUsingInterstitialList: (nonnull NSArray *)interstitialList
                            andRewardedList: (nonnull NSArray *)rewardedList
                                 completion: (nonnull UADSGMAScarSignalsCompletion *)completion {
    __block UADSMutableScarSignals *signals = [[UADSMutableScarSignals alloc] init];
    __block id<UADSError> signalError;
    dispatch_group_t group = dispatch_group_create();

    [self getSignalsOfType: GADQueryInfoAdTypeInterstitial
                      list: interstitialList
                signalsMap: signals
                     group: group
                     error: ^(id<UADSError> returnedError) {
                         signalError = returnedError;
                     }];

    [self getSignalsOfType: GADQueryInfoAdTypeRewarded
                      list: rewardedList
                signalsMap: signals
                     group: group
                     error: ^(id<UADSError> returnedError) {
                         signalError = returnedError;
                     }];

    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if (signals.count == 0 && signalError) {
            [completion error: signalError];
        } else {
            [completion success: signals];
        }
    });
}

- (void)updateSignals: (UADSSCARSignals *)signals
           withSignal: (NSString *)signal
       forPlacementID: (NSString *)placementID {
    dispatch_sync(self.syncQueue, ^{
        [signals setValue: signal
                   forKey: placementID];
    });
}

- (void)getSignalsOfType: (GADQueryInfoAdType)adType
                    list: (NSArray *)list
              signalsMap: (UADSSCARSignals *)signals
                   group: (dispatch_group_t)group
                   error: (ReturnErrorCompletion)error {
    for (NSString *placementID in list) {
        dispatch_group_enter(group);

        UADSGMASCARCompletion *completion = [self completionForPlacement: placementID
                                                              signalsMap: signals
                                                                   group: group
                                                                   error: error];
        [self.signalService getSignalOfAdType: adType
                               forPlacementId: placementID
                                   completion: completion];
    }
}

- (UADSGMASCARCompletion *)completionForPlacement: (NSString *)placementID
                                       signalsMap: (UADSSCARSignals *)signals
                                            group: (dispatch_group_t)group
                                            error: (ReturnErrorCompletion)error {
    __weak typeof(self) weakSelf = self;
    return [UADSGMASCARCompletion newWithSuccess: ^(NSString *_Nullable signal) {
        [weakSelf updateSignals: signals
                     withSignal: signal
                 forPlacementID: placementID];
        dispatch_group_leave(group);
    }
                                        andError: ^(id<UADSError> _Nonnull returnedError) {
                                            error(returnedError);
                                            dispatch_group_leave(group);
                                        }];
}

- (GADRequestBridge *)getAdRequestFor: (GMAAdMetaData *)meta
                                error: (id<UADSError>  _Nullable __autoreleasing *)error {
    return [self.signalService getAdRequestFor: meta
                                         error: error];
}

@end
