#import <Foundation/Foundation.h>
#import "GMAQuerySignalReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMABaseQuerySignalReaderV85 : NSObject<GMASignalService>
- (instancetype)__unavailable init;
+ (instancetype)newWithInfoReader: (id<GMAQueryInfoReader>)reader;
+ (BOOL)isSupported;
@end

NS_ASSUME_NONNULL_END
