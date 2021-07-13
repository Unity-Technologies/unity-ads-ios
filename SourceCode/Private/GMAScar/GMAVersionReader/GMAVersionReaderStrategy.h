#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kGMAVersionReaderUnavailableVersionString = @"0.0.0";

@interface GMAVersionReaderStrategy : NSObject
- (NSString *)sdkVersion;
@end

NS_ASSUME_NONNULL_END
