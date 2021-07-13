#import <Foundation/Foundation.h>
#import "GMASCARSignalsReader.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMASCARSignalsReaderMock : NSObject<GMASCARSignalsReader>

- (void)emulateReturnOfAnEmptyDictionary;

- (void)emulateReturnOfNil;

- (void)emulateReturnOfADictionary: (UADSSCARSignals *)dictionary;

@end

NS_ASSUME_NONNULL_END
