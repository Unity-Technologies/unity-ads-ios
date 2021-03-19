#import <Foundation/Foundation.h>
#import "UADSProxyReflection.h"
NS_ASSUME_NONNULL_BEGIN

/**
 Class the reflectively creates SKAdImpression.
 Expects the JSON of format
 NSDictionary* skadImressionJSON = @{
     @"version": @"2.2", //String
     @"signature": @"jdklsjds", //String
     @"adNetworkIdentifier": @"adNetworkIdentifier", //String
     @"adCampaignIdentifier": @1, // Number
     @"advertisedAppStoreItemIdentifier": @1, //Number
     @"adImpressionIdentifier": @"adImpressionIdentifier", String
     @"sourceAppStoreItemIdentifier": @1, //Number
     @"timestamp": @0, //Number
     @"adType": @"adType"//String optional
     @"adDescription": @"adDescription"//String optional
     @"adPurchaserName": @"adPurchaserName"//String optional
 };
 
 */

@interface SKAdImpressionProxy: UADSProxyReflection

+(instancetype)newFromJSON: (NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
