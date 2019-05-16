#import "UADSVideoPlayerHandler.h"
#import "UADSViewController.h"

@implementation UADSVideoPlayerHandler

- (BOOL)create:(UADSViewController *)viewController {
    if (![self videoView]) {
        [self setVideoView:[[UADSVideoView alloc] initWithFrame:[self getRect:viewController.view]]];
        [self.videoView setVideoFillMode:AVLayerVideoGravityResizeAspect];
    }

    if (![self videoPlayer]) {
        AVURLAsset *asset = nil;
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        [self setVideoPlayer:[[UADSAVPlayer alloc] initWithPlayerItem:item]];
        [self.videoView setPlayer:self.videoPlayer];
    }

    return true;
}

- (BOOL)destroy {
    if ([self videoPlayer]) {
        [self.videoPlayer stop];
        [self.videoPlayer stopObserving];
    }

    self.videoPlayer = NULL;

    if ([self videoView]) {
        [self.videoView removeFromSuperview];
    }
    
    self.videoView = NULL;

    return true;
}

- (UIView *)getView {
    return self.videoView;
}

- (void)viewDidLoad:(UADSViewController *)viewController {
}

- (void)viewDidAppear:(UADSViewController *)viewController animated:(BOOL)animated {
}

- (void)viewWillAppear:(UADSViewController *)viewController animated:(BOOL)animated {
}

- (void)viewWillDisappear:(UADSViewController *)viewController animated:(BOOL)animated {
}

- (void)viewDidDisappear:(UADSViewController *)viewController animated:(BOOL)animated {
    [self destroy];
}

@end
