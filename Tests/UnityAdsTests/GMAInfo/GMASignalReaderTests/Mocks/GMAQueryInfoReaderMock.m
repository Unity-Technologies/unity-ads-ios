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
@property (nonatomic, strong) CompletionsList *intCompletions;
@property (nonatomic, strong) CompletionsList *rewCompletions;
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
        case GADQueryInfoAdTypeInterstitial:
            return _intCompletions;

        case  GADQueryInfoAdTypeRewarded:
            return _rewCompletions;
    }
}

- (NSUInteger)numberOfCallsForType: (GADQueryInfoAdType)type {
    switch (type) {
        case GADQueryInfoAdTypeRewarded:
            return _rewardCalls;

        case GADQueryInfoAdTypeInterstitial:
            return _intCalls;
    }
}

@end
