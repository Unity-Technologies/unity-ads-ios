#import "UADSProperties.h"

int const UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT = 5000;

@implementation UADSProperties

static id<UnityAdsDelegate> _delegate = nil;
static NSMutableOrderedSet<id<UnityAdsDelegate>> *_delegates = nil;
static int _showTimeout = UADSPROPERTIES_DEFAULT_SHOW_TIMEOUT;

+ (void)initialize {
    if (self == [UADSProperties class]) {
        _delegates = [[NSMutableOrderedSet alloc] init];
    }    
}

// Public

+(void)setDelegate:(id <UnityAdsDelegate>)delegate {
    // cleanup possible reference in _delegates
    if (_delegate) {
        @synchronized(_delegates) {
            [_delegates removeObject:_delegate];
        }
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

    if (delegate) {
        @synchronized(_delegates) {
            [_delegates addObject:delegate];
        }
    }
}

+(NSOrderedSet<id <UnityAdsDelegate>> *)getDelegates {
    @synchronized(_delegates) {
        NSMutableOrderedSet *mutableOrderedSet = [[NSMutableOrderedSet alloc] initWithOrderedSet:_delegates];
        
        if (_delegate) {
            [mutableOrderedSet addObject:_delegate];
        }
        return [[NSOrderedSet alloc] initWithOrderedSet:mutableOrderedSet];
    }
    
}

+(void)removeDelegate:(id <UnityAdsDelegate>)delegate {
    // cleanup possible reference in _listener
    if (_delegate && [_delegate isEqual:delegate]) {
        _delegate = nil;
    }

    if (delegate) {
        @synchronized(_delegates) {
            [_delegates removeObject:delegate];
        }
    }
}

+(void)setShowTimeout:(int)timeout {
    _showTimeout = timeout;
}

+(int)getShowTimeout {
    return _showTimeout;
}

@end
