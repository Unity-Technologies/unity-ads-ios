#import <Foundation/Foundation.h>

@protocol UADSLoadBridgeProtocol

-(void)loadPlacements:(NSDictionary<NSString*, NSNumber*> *)placements;

@end

@interface UADSLoadBridge : NSObject <UADSLoadBridgeProtocol>

-(void)loadPlacements:(NSDictionary<NSString*, NSNumber*> *)placements;

@end
