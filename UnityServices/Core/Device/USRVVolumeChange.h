@protocol USRVVolumeChangeDelegate <NSObject>

- (void)onVolumeChanged:(float)volume;

@end

@interface USRVVolumeChange : NSObject

+ (void)startObserving;
+ (void)stopObserving;
+ (void)registerDelegate:(id<USRVVolumeChangeDelegate>)delegate;
+ (void)unregisterDelegate:(id<USRVVolumeChangeDelegate>)delegate;
+ (void)clearAllDelegates;

@end
