#import "UADSProperties.h"

int const UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT = 5000;

@implementation UADSProperties

static id<UnityAdsDelegate> _delegate = nil;
static NSMutableOrderedSet<id<UnityAdsDelegate>> *_delegates = nil;
static int _showTimeout = UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT;

// Public

+(void)setDelegate:(id <UnityAdsDelegate>)delegate {
    // cleanup possible reference in _delegates
    if (_delegate) {
        [UADSProperties initializeDelegates];
        [_delegates removeObject:_delegate];
    }
    _delegate = delegate;
}

+(__nullable id <UnityAdsDelegate>)getDelegate {
    return _delegate;
}

+(void)addDelegate:(id <UnityAdsDelegate>)delegate {
    // needed to bridge set/get listener and add/remove listener
    if (_delegate == nil) {
        _delegate = delegate;
    }

    [UADSProperties initializeDelegates];
    if (delegate) {
        [_delegates addObject:delegate];
    }
}

+(NSOrderedSet<id <UnityAdsDelegate>> *)getDelegates {
    [UADSProperties initializeDelegates];
    NSMutableOrderedSet *mutableOrderedSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:_delegates];
    if (_delegate) {
        [mutableOrderedSet addObject:_delegate];
    }
    return [[NSOrderedSet alloc] initWithOrderedSet:mutableOrderedSet];
}

+(void)removeDelegate:(id <UnityAdsDelegate>)delegate {
    // cleanup possible reference in _listener
    if (_delegate && [_delegate isEqual:delegate]) {
        _delegate = nil;
    }

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
