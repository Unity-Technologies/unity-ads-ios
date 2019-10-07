#import <Foundation/Foundation.h>
#include <AudioToolbox/AudioToolbox.h>

@interface USRVMuteSwitch : NSObject

+ (USRVMuteSwitch *)sharedInstance;

- (void)detectMuteSwitch;

@end
