#import "USRVInitializeStateLoadConfigFile.h"
#import "USRVSdkProperties.h"
#import "USRVInitializeStateReset.h"

@implementation USRVInitializeStateLoadConfigFile : USRVInitializeState

- (instancetype)execute {
    USRVConfiguration *localConfig;

    @try {
        if ([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]]) {
            NSData *configData = [NSData dataWithContentsOfFile: [USRVSdkProperties getLocalConfigFilepath]
                                                        options: NSDataReadingUncached
                                                          error: nil];
            localConfig = [[USRVConfiguration alloc] initWithConfigJsonData: configData];

            self.configuration = localConfig;
            USRVLogDebug(@"Unity Ads init: Using cached configuration parameters");
        }
    } @catch (NSException *exception) {
        USRVLogDebug(@"Unity Ads init: Using default configuration parameters");
    } @finally {
        id nextState = [[USRVInitializeStateReset alloc] initWithConfiguration: self.configuration];
        return nextState;
    }
}

@end
