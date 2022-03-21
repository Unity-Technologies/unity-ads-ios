#import <Foundation/Foundation.h>
#import "UADSConfigurationEndpointProvider.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationEndpointProviderMock : NSObject<UADSHostnameProvider>
@property (nonatomic, strong) NSString *hostname;
@end

NS_ASSUME_NONNULL_END
