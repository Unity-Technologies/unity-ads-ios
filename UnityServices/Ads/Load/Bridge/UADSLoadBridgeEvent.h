#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UADSLoadBridgeEvent) {
    UADSLoadEventLoadPlacements
};

NSString *NSStringFromUADSLoadBridgeEvent(UADSLoadBridgeEvent event);

