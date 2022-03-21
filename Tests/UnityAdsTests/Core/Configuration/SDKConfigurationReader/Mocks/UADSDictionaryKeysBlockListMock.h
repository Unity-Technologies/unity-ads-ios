#import <UIKit/UIKit.h>
#import "UADSDeviceInfoReaderWithFilter.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDictionaryKeysBlockListMock : NSObject<UADSDictionaryKeysBlockList>
@property (nonatomic, strong) NSArray<NSString *> *keysToSkip;
@end

NS_ASSUME_NONNULL_END
