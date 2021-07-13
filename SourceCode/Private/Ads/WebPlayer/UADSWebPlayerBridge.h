#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>

@interface UADSWebPlayerBridge : NSObject

+ (void)sendFrameUpdate: (NSString *)viewId frame: (CGRect)frame alpha: (CGFloat)alpha;

+ (void)sendGetFrameResponse: (NSString *)callId viewId: (NSString *)viewId frame: (CGRect)frame alpha: (CGFloat)alpha;

@end
