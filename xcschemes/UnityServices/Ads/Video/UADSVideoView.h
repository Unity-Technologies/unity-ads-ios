#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface UADSVideoView : UIView

@property (nonatomic) AVPlayer *player;

+ (Class)layerClass;
- (void)setPlayer:(AVPlayer *)player;
- (void)setVideoFillMode:(NSString *)fillMode;
- (AVPlayer*)player;

@end