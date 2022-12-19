#import "UADSGMAScarForTest.h"
#import "GMAQueryInfoReaderWithRequestId.h"

@interface UADSGMAScarForTest()
@property (nonatomic, strong) GMAQueryInfoReaderWithRequestId *queryWithRequestId;

@end

@implementation UADSGMAScarForTest

- (id<GMAQueryInfoReader>)queryInfoReader {
    id<GMAQueryInfoReader> queryInfoReader = [super queryInfoReader];
    _queryWithRequestId = [GMAQueryInfoReaderWithRequestId newWithOriginal: queryInfoReader];
    return _queryWithRequestId;
}

- (NSString*)lastRequestId {
    return [_queryWithRequestId lastRequestId];
}

@end
