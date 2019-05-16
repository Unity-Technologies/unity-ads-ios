#import "UMONPlacementContent.h"
#import "USRVWebViewApp.h"
#import "UMONWebViewEventCategory.h"
#import "UMONPlacementContentEvent.h"

@implementation UMONCustomEvent (JsonAdditions)
-(NSDictionary*)getJsonDictionary {
    return @{
        @"category": self.category ? self.category : [NSNull null],
        @"type": self.type ? self.type : [NSNull null],
        @"data": self.userInfo ? self.userInfo : [NSNull null]
    };
}
@end

@interface UMONPlacementContent ()
@property(strong, nonatomic) NSString *type;
@property(retain, nonatomic) NSString *placementId;
@end

@implementation UMONPlacementContent
-(instancetype)initWithPlacementId:(NSString *)placementId withParams:(NSDictionary *)params {
    if (self = [super init]) {
        _placementId = placementId;
        _type = [params valueForKey:@"type"];
        _userInfo = [NSDictionary dictionaryWithDictionary:params];
    }
    return self;
}

-(BOOL)isReady {
    return _state == kPlacementContentStateReady;
}

-(void)sendCustomEvent:(UMONCustomEvent*)customEvent {
    if (![[customEvent category] length]) {
        customEvent.category = self.defaultEventCategory;
    }

    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        NSDictionary* eventData = [customEvent getJsonDictionary];
        [app sendEvent:NSStringFromPlacementContentEvent(kPlacementContentEventCustom)
              category:NSStringFromMonetizationWebViewEventCategory(kWebViewEventCategoryPlacementContent)
                param1:self.placementId, eventData, nil];
    } else {
        USRVLogWarning(@"Could not send custom event due to app being null");
    }
}

-(void)sendCustomEvent:(NSString *)type withUserInfo:(NSDictionary<NSString *, NSObject *> *)userInfo {
    [self sendCustomEvent:[UMONCustomEvent build:^(UMONCustomEventBuilder* builder) {
        builder.type = type;
        builder.userInfo = userInfo;
    }]];
}
-(void)sendCustomEventWithType:(NSString *)type {
    [self sendCustomEvent:type withUserInfo:nil];
}

-(NSString*)defaultEventCategory {
    return @"PLACEMENT_CONTENT";
}

@end
