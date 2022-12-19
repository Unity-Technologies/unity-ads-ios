#import <Foundation/Foundation.h>
#import "GMAQueryInfoReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMAQueryInfoReaderWithRequestId :  NSObject<GMAQueryInfoReader>

+ (instancetype)newWithOriginal:(id<GMAQueryInfoReader>)original;
- (NSString *)lastRequestId;

@end

NS_ASSUME_NONNULL_END
