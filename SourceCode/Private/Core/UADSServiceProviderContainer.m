#import "UADSServiceProviderContainer.h"
#import "UADSTools.h"

@implementation UADSServiceProviderContainer
_uads_custom_singleton_imp(UADSServiceProviderContainer, ^{
    return [self new];
})

- (instancetype)init {
    SUPER_INIT
    _serviceProvider = [UADSServiceProvider new];
    return self;
}
@end
