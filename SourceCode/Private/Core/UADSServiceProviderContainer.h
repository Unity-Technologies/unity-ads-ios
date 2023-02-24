#import <Foundation/Foundation.h>
#import "UADSServiceProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSServiceProviderContainer : NSObject
+ (instancetype)                         sharedInstance;
@property (nonatomic) UADSServiceProvider *serviceProvider;
@end

NS_ASSUME_NONNULL_END
