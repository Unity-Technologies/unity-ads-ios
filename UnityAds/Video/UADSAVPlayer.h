
#import <AVFoundation/AVFoundation.h>

@interface UADSAVPlayer : AVPlayer

@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) int progressInterval;
@property (nonatomic, assign) BOOL isPlaying;

- (void)setProgressEventInterval:(int)progressEventInterval;
- (void)prepare:(NSString *)url initialVolume:(float)volume;
- (void)stop;
- (void)stopObserving;
- (void)seekTo:(int)msec;
- (int)getCurrentPosition;

@end