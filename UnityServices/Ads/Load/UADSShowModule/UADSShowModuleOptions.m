#import "UADSShowModuleOptions.h"
#import "USRVClientProperties.h"
#import "UADSAbstractModuleOperationBasicObject.h"

@interface UADSShowModuleOptions ()

@end

@implementation UADSShowModuleOptions

- (NSDictionary *)displayOptions {
    return  @{
        kSupportedOrientationsKey : [NSNumber numberWithInt: _supportedOrientations],
        kSupportedOrientationsPlistKey : _supportedOrientationsPlist,
        kStatusBarOrientationKey : [NSNumber numberWithInteger: _statusBarOrientation],
        kStatusBarHiddenKey : [NSNumber numberWithBool: _isStatusBarHidden],
        kUADSShowModuleStateRotationKey: [NSNumber numberWithBool: _shouldAutorotate]
    };
}

- (NSDictionary *)dictionary {
    return @{
        kUADSShowModuleStateDisplayOptionsKey: self.displayOptions,
        kUADSHeaderBiddingOptionsDictionaryKey: self.options.dictionary
    };
}


@end
