#import "GMAQueryInfoReaderWithRequestId.h"

@interface GMAQueryInfoReaderWithRequestId ()

@property (nonatomic, strong) id<GMAQueryInfoReader>original;
@property (nonatomic, strong) NSMutableArray *requestIds;
@end

@implementation GMAQueryInfoReaderWithRequestId

+ (instancetype)newWithOriginal:(id<GMAQueryInfoReader>)original {
    GMAQueryInfoReaderWithRequestId *reader = [GMAQueryInfoReaderWithRequestId new];
    reader.original = original;
    reader.requestIds = [NSMutableArray array];
    return reader;
    
}
- (NSString *)lastRequestId {
    return [self.requestIds lastObject];
}


- (void)getQueryInfoOfFormat:(GADQueryInfoAdType)type completion:(nonnull GADQueryInfoBridgeCompletion *)completion {
    __weak GMAQueryInfoReaderWithRequestId *weakSelf = self;
    id successHandler = ^(GADQueryInfoBridge *_Nullable info) {
        [weakSelf.requestIds addObject: info.requestIdentifier];
        [completion success: info];
    };
    
    id errorHandler = ^(id<UADSError> _Nonnull error) {
        [completion error: error];
    };
    
    GADQueryInfoBridgeCompletion *completionHandler = [GADQueryInfoBridgeCompletion newWithSuccess: successHandler
                                                                                          andError: errorHandler];
    [self.original getQueryInfoOfFormat:type completion:completionHandler];
}

@end
