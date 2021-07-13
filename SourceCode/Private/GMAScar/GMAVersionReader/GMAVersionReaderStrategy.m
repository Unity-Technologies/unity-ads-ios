#import "GMAVersionReaderStrategy.h"
#import "GMAVersionReaderV7.h"
#import "GMAVersionReaderV8.h"

@interface GMAVersionReaderStrategy ()
@property (nonatomic, copy) NSString *sdkVersion;
@end

@implementation GMAVersionReaderStrategy

- (instancetype)init {
    SUPER_INIT

    if ([GMAVersionReaderV8 exists]) {
        self.sdkVersion = [GMAVersionReaderV8 sdkVersion];
        return self;
    }

    if ([GMAVersionReaderV7 exists]) {
        self.sdkVersion = [GMAVersionReaderV7 sdkVersion];
        return self;
    }

    self.sdkVersion = kGMAVersionReaderUnavailableVersionString;
    return self;
}

@end
