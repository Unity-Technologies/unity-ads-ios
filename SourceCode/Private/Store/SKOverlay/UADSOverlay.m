#import "UADSOverlay.h"
#import "UADSOverlayEventHandler.h"
#import "UADSOverlayDelegateProxy.h"
#import "SKOverlayAppConfiguration+Dictionary.h"
#import "UIViewController+WindowScene.h"

@interface UADSOverlay ()
@property (nonatomic, strong) id<UADSOverlayEventProtocol> handler;
@property (nonatomic, strong) UADSOverlayDelegateProxy *overlayDelegate;
@property (nonatomic, strong) NSString *currentAppIdentifier;
@end

@implementation UADSOverlay

+ (instancetype)sharedInstance {
    UADS_SHARED_INSTANCE(onceToken, ^{
        UADSWebViewEventSenderBase *webViewEventSender = [[UADSWebViewEventSenderBase alloc] init];
        return [[UADSOverlay alloc] initWithEventHandler: [[UADSOverlayEventHandler alloc] initWithEventSender: webViewEventSender]];
    });
}

- (instancetype)initWithEventHandler: (id<UADSOverlayEventProtocol>)handler {
    SUPER_INIT
        _handler = handler;

    _overlayDelegate = [[UADSOverlayDelegateProxy alloc] initWithEventHandler: self.handler];

    return self;
}

- (void)show: (NSDictionary *)configDictionary {
    if (@available(iOS 14.0, *)) {
        UIWindowScene *scene = [UIViewController uads_currentWindowScene];

        if (scene == nil) {
            [self.handler sendOverlayDidFailToLoad: kOverlaySceneNotFound];
            return;
        }

        SKOverlayAppConfiguration *config = [SKOverlayAppConfiguration uads_overlayAppConfigurationFrom: configDictionary];

        if (config == nil) {
            [self.handler sendOverlayDidFailToLoad: kOverlayInvalidParamaters];
            return;
        }

        if ([self.currentAppIdentifier isEqualToString: config.appIdentifier]) {
            [self.handler sendOverlayDidFailToLoad: kOverlayAlreadyShown];
            return;
        }

        self.currentAppIdentifier = config.appIdentifier;

        SKOverlay *overlay = [[SKOverlay alloc] initWithConfiguration: config];
        overlay.delegate = self.overlayDelegate;

        [overlay presentInScene: scene];
    } else {
        [self.handler sendOverlayDidFailToLoad: kOverlayNotAvailable];
    }
}

- (void)hide {
    if (@available(iOS 14.0, *)) {
        UIWindowScene *scene = [UIViewController uads_currentWindowScene];
        [SKOverlay dismissOverlayInScene: scene];
        self.currentAppIdentifier = nil;
    }
}

@end
