#import <Foundation/Foundation.h>
#import "UADSInitializationStatusReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSInitializationStatusReaderMock : NSObject<UADSInitializationStatusReader>
@property (nonatomic) InitializationState currentState;
@end

NS_ASSUME_NONNULL_END
