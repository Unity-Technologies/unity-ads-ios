#import <Foundation/Foundation.h>
#import "GMAQuerySignalReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADRequestFactoryMock : NSObject<GADRequestFactory>
@property (nonatomic) id<UADSError> returnedError;
@end

NS_ASSUME_NONNULL_END
