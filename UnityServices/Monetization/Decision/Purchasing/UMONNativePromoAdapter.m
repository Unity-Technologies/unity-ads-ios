#import "UMONNativePromoAdapter.h"

static NSString* nativePromoShowTypeFull = @"FULL";
static NSString* nativePromoShowTypePreview = @"PREVIEW";

NSString *NSStringFromNativePromoShowType(UMONNativePromoShowType type) {
    switch (type) {
        case kNativePromoShowTypeFull:
            return nativePromoShowTypeFull;
        case kNativePromoShowTypePreview:
            return nativePromoShowTypePreview;
    }
}

@interface UMONNativePromoAdapter ()
@property(nonatomic, strong) UMONPromoAdPlacementContent *promo;
@end

static NSString* nativePromoCustomEventTypeShown            = @"shown";
static NSString* nativePromoCustomEventShownShowTypeKey     = @"showType";
static NSString* nativePromoCustomEventTypeClosed           = @"closed";
static NSString* nativePromoCustomEventTypeClicked          = @"clicked";

@implementation UMONNativePromoAdapter
-(instancetype)initWithPromo:(UMONPromoAdPlacementContent *)promo {
    if (self = [super init]) {
        self.promo = promo;
    }
    return self;
}

-(void)promoDidShow {
    [self promoDidShow:kNativePromoShowTypeFull];
}

-(void)promoDidShow:(UMONNativePromoShowType)showType {
    NSDictionary *eventData = @{
        nativePromoCustomEventShownShowTypeKey: NSStringFromNativePromoShowType(showType)
    };
    [self.promo sendCustomEvent:nativePromoCustomEventTypeShown withUserInfo:eventData];
}

-(void)promoDidClick {
    [self.promo sendCustomEventWithType:nativePromoCustomEventTypeClicked];
}

-(void)promoDidClose {
    [self.promo sendCustomEventWithType:nativePromoCustomEventTypeClosed];
}

-(UMONPromoMetaData *)metadata {
    return [self.promo metadata];
}

@end
