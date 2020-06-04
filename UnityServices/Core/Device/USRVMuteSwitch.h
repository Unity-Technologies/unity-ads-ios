#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

@interface USRVMuteSwitch : NSObject

+ (USRVMuteSwitch *)sharedInstance;

- (NSString *)getMuteDetectionFilePath;

- (bool)writeToMuteDetectionPath:(NSString *)filePath;

- (void)detectMuteSwitch;

- (void)playbackComplete;

- (void)sendMuteState:(bool)muteState;

@end
