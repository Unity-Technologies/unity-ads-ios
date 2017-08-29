@protocol UADSVolumeChangeDelegate <NSObject>

- (void)onVolumeChanged:(float)volume;

@end

@interface UADSVolumeChange : NSObject

+ (void)startObserving;
+ (void)stopObserving;
+ (void)registerDelegate:(id<UADSVolumeChangeDelegate>)delegate;
+ (void)unregisterDelegate:(id<UADSVolumeChangeDelegate>)delegate;
+ (void)clearAllDelegates;

@end
