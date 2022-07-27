#import <Foundation/Foundation.h>
#import "NSBundle+TypecastGet.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSPlistReaderMock : NSObject<UADSPlistReader>
@property (nonatomic, strong) NSString *_Nullable expectedValue;
@end

NS_ASSUME_NONNULL_END
