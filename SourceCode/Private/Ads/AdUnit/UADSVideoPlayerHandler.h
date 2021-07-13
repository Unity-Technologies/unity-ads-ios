#import "UADSAdUnitViewHandler.h"
#import "UADSAVPlayer.h"
#import "UADSVideoView.h"

@interface UADSVideoPlayerHandler : UADSAdUnitViewHandler

@property (nonatomic, strong) UADSAVPlayer *videoPlayer;
@property (nonatomic, strong) UADSVideoView *videoView;

@end
