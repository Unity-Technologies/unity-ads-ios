#import "GMAQueryInfoReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMAQueryInfoMock : NSObject
@property (nonatomic, strong, readonly) NSString *requestIdentifier;
@end

@interface GMAQueryInfoReaderMock : NSObject<GMAQueryInfoReader>
- (void)callSuccessWithQuery: (GADQueryInfoBridge *)query
                   forAdType: (GADQueryInfoAdType)type;

- (void)callErrorWith: (id<UADSError>)error
            forAdType: (GADQueryInfoAdType)type;

- (NSUInteger)numberOfCallsForType: (GADQueryInfoAdType)type;
@end

NS_ASSUME_NONNULL_END
