#import "UADSProperties.h"

int const UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT = 5000;

@implementation UADSProperties

static NSMutableOrderedSet<id<UnityAdsDelegate>> *_delegates = nil;
static int _showTimeout = UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT;

// Public

+(void)addDelegate:(id <UnityAdsDelegate>)delegate {
    [UADSProperties initializeDelegates];
    if (delegate) {
        [_delegates addObject:delegate];
    }
}

+(NSOrderedSet<id <UnityAdsDelegate>> *)getDelegates {
    [UADSProperties initializeDelegates];
    return [[NSOrderedSet alloc] initWithOrderedSet:_delegates];
}

+(void)removeDelegate:(id <UnityAdsDelegate>)delegate {
    [UADSProperties initializeDelegates];
    if (delegate) {
        [_delegates removeObject:delegate];
    }
}

+(void)setShowTimeout:(int)timeout {
    _showTimeout = timeout;
}

+(int)getShowTimeout {
    return _showTimeout;
}

// Private

+(void)initializeDelegates {
    if (!_delegates) {
        // only create delegates if nil
        _delegates = [[NSMutableOrderedSet alloc] init];
    }
}

@end
