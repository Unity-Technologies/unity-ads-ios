#import "GMASCARSignalsReader.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GMASCARSignalServiceMock : NSObject <GMASCARSignalService>

@property (nonatomic, strong) NSArray<UADSScarSignalParameters *> *requestedSignals;

- (void)callSuccessCompletion:(UADSSCARSignals *)result;
- (void)callErrorCompletion:(id<UADSError>)error;

@end

NS_ASSUME_NONNULL_END
