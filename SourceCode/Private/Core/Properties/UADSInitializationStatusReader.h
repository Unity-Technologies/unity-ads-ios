#import <Foundation/Foundation.h>
#import "USRVSdkProperties.h"
NS_ASSUME_NONNULL_BEGIN

@protocol UADSInitializationStatusReader <NSObject>

- (InitializationState)currentState;

@end

@interface UADSInitializationStatusReaderBase : NSObject<UADSInitializationStatusReader>

@end

NSString * UADSStringFromInitializationState(InitializationState state);

NS_ASSUME_NONNULL_END
