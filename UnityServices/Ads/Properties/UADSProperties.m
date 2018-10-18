#import "UADSProperties.h"

@implementation UADSProperties

static id<UnityAdsDelegate> _delegate = nil;
static int showTimeout = 5000;

+ (void)setDelegate:(id<UnityAdsDelegate>)delegate; {
    _delegate = delegate;
}

+ (id<UnityAdsDelegate>)getDelegate {
    return _delegate;
}

+ (void)setShowTimeout:(int)timeout {
    showTimeout = timeout;
}

+ (int)getShowTimeout {
    return showTimeout;
}

@end
