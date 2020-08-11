#import <Foundation/Foundation.h>
#import "USRVWebViewApp.h"

@interface USRVSKAdNetworkProxy : NSObject

+(USRVSKAdNetworkProxy*)sharedInstance;
-(BOOL)available;
-(void)updateConversionValue:(NSInteger)conversionValue;
-(void)registerAppForAdNetworkAttribution;

@end
