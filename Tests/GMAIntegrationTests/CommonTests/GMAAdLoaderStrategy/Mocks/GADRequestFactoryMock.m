
#import "GADRequestFactoryMock.h"
#import "UADSTools.h"
@implementation GADRequestFactoryMock


- (nullable GADRequestBridge *)getAdRequestFor: (nonnull GMAAdMetaData *)meta
                                         error: (id<UADSError>  _Nullable __autoreleasing *_Nullable)error {
    if (_returnedError) {
        *error = _returnedError;
    }

    return [GADRequestBridge getNewRequest];
}

@end
