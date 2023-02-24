#import "UADSSharedSessionIdReader.h"
#import "UADSSessionId.h"

@implementation UADSSharedSessionIdReaderBase

- (nonnull NSString *)sessionId {
    return UADSSessionId.shared.sessionId;
}

@end
