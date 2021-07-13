#import "UADSWebViewEvent.h"

@interface UADSWebViewEventBase ()
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *event;
@property (nonatomic, strong) NSArray *_Nullable paramArray;
@end


@implementation UADSWebViewEventBase

+ (instancetype)newWithCategory: (NSString *)category
                      withEvent: (NSString *)event
                     withParams: (NSArray *)params {
    UADSWebViewEventBase *base = [UADSWebViewEventBase new];

    base.category = category;
    base.event = event;
    base.paramArray = params;
    return base;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat: @"<%@: %p>\n\t CATEGORY: %@ \n\t EVENT: %@ \n\t PARAMS: %@", [self class], self, _category, _event, _paramArray];
}

- (nonnull NSString *)categoryName {
    return _category;
}

- (nonnull NSString *)eventName {
    return _event;
}

- (NSArray *_Nullable)params {
    return _paramArray;
}

@end
