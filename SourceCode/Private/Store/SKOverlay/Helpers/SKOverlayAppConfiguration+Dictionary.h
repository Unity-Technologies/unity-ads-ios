#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKOverlayAppConfiguration (Dictionary)
+ (SKOverlayAppConfiguration *)uads_overlayAppConfigurationFrom: (NSDictionary *)dictionary API_AVAILABLE(ios(14.0));
@end
