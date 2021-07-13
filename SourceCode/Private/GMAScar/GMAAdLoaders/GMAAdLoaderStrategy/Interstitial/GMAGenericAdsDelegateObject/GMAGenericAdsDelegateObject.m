#import "GMAGenericAdsDelegateObject.h"

@interface GMAGenericAdsDelegateObject ()
@property (strong, nonatomic) id storedAd;
@property (strong, nonatomic) id storedDelegate;
@end

@implementation GMAGenericAdsDelegateObject

+ (instancetype)newWithAd: (id)ad delegate: (id)delegate {
    GMAGenericAdsDelegateObject *obj = [self new];

    obj.storedAd = ad;
    obj.storedDelegate = delegate;
    return obj;
}

@end
