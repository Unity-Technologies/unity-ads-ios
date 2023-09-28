#import "GMAQueryInfoReaderMock.h"
#import "GADQueryInfoBridge.h"
#import "NSError+UADSError.h"
#import "UADSTools.h"

@implementation GMAQueryInfoMock : NSObject
    @synthesize requestIdentifier;
@end

typedef NSMutableArray<GADQueryInfoBridgeCompletion *> CompletionsList;

@interface GMAQueryInfoReaderMock ()
@property (nonatomic, assign) NSUInteger rewardCalls;
@property (nonatomic, assign) NSUInteger intCalls;
@property (nonatomic, assign) NSUInteger bannerCalls;
@property (nonatomic, strong) CompletionsList *intCompletions;
@property (nonatomic, strong) CompletionsList *rewCompletions;
@property (nonatomic, strong) CompletionsList *bannerCompletions;
@end

@implementation GMAQueryInfoReaderMock
- (instancetype)init {
    SUPER_INIT
    self.intCompletions = [[NSMutableArray alloc] init];
    self.rewCompletions = [[NSMutableArray alloc] init];
    return self;
}

- (void)getQueryInfoOfFormat: (GADQueryInfoAdType)type
                  completion: (nonnull GADQueryInfoBridgeCompletion *)completion {
    switch (type) {
        case GADQueryInfoAdTypeBanner:
            _bannerCalls += 1;
            [_bannerCompletions addObject: completion];
            break;
        case GADQueryInfoAdTypeInterstitial:
            _intCalls += 1;
            [_intCompletions addObject: completion];
            break;

        case GADQueryInfoAdTypeRewarded:
            _rewardCalls += 1;
            [_rewCompletions addObject: completion];
            break;
    }
}

- (void)callSuccessWithQuery: (GADQueryInfoBridge *)query
                   forAdType: (GADQueryInfoAdType)type {
    [[self getAndRemoveLastCompletionForAdType: type] success: query];
}

- (void)callErrorWith: (id<UADSError>)error
            forAdType: (GADQueryInfoAdType)type {
    [[self getAndRemoveLastCompletionForAdType: type] error: error];
}

- (GADQueryInfoBridgeCompletion *)getAndRemoveLastCompletionForAdType: (GADQueryInfoAdType)type {
    GADQueryInfoBridgeCompletion *completion;
    CompletionsList *list = [self getListOfType: type];

    completion = [list lastObject];
    [list removeLastObject];
    return completion;
}

- (CompletionsList *)getListOfType: (GADQueryInfoAdType)type  {
    switch (type) {
        case GADQueryInfoAdTypeBanner:
            return _bannerCompletions;
            
        case GADQueryInfoAdTypeInterstitial:
            return _intCompletions;

        case  GADQueryInfoAdTypeRewarded:
            return _rewCompletions;
    }
}

- (NSUInteger)numberOfCallsForType: (GADQueryInfoAdType)type {
    switch (type) {
        case GADQueryInfoAdTypeBanner:
            return _bannerCalls;
            
        case GADQueryInfoAdTypeRewarded:
            return _rewardCalls;

        case GADQueryInfoAdTypeInterstitial:
            return _intCalls;
            
    }
}

@end
