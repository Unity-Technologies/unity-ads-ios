#import "UADSOverlayWebViewEvent.h"

@implementation UADSOverlayWebViewEvent

+ (instancetype)newWithEventName: (NSString *)event params: (NSArray *)params {
    return [UADSOverlayWebViewEvent newWithCategory: @"SKOVERLAY"
                                          withEvent: event
                                         withParams: params];
}

+ (instancetype)newWillStartPresentation {
    return [UADSOverlayWebViewEvent newWithEventName: @"WILL_START_PRESENTATION"
                                              params: nil];
}

+ (instancetype)newDidFinishPresentation {
    return [UADSOverlayWebViewEvent newWithEventName: @"DID_FINISH_PRESENTATION"
                                              params: nil];
}

+ (instancetype)newWillStartDismissal {
    return [UADSOverlayWebViewEvent newWithEventName: @"WILL_START_DISMISSAL"
                                              params: nil];
}

+ (instancetype)newDidFinishDismissal {
    return [UADSOverlayWebViewEvent newWithEventName: @"DID_FINISH_DISMISSAL"
                                              params: nil];
}

+ (instancetype)newDidFailToLoadWithParams: (NSArray *)params {
    return [UADSOverlayWebViewEvent newWithEventName: @"DID_FAIL_TO_LOAD"
                                              params: params];
}

@end
