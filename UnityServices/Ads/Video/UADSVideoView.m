#import "UADSVideoView.h"

@implementation UADSVideoView

+(Class)layerClass {
    return [AVPlayerLayer class];
}

-(AVPlayer *)player {
    return [(AVPlayerLayer *) [self layer] player];
}

-(void)setVideoFillMode:(NSString *)fillMode {
    AVPlayerLayer *playerLayer = (AVPlayerLayer *) [self layer];
    playerLayer.videoGravity = fillMode;
    [self layer].bounds = [self layer].bounds;
}

-(void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *) [self layer] setPlayer:player];
}

-(CGRect)getPlayerRect {
    AVPlayerLayer *playerLayer = (AVPlayerLayer *) [self layer];
    return [playerLayer videoRect];
}

@end
