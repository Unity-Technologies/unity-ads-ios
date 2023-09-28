#import "UADSGenericCompletion.h"
#import "GMASCARSignalsReader.h"
#import "UADSScarSignalParameters.h"

NS_ASSUME_NONNULL_BEGIN
typedef UADSGenericCompletion<NSString *> UADSGMAEncodedSignalsCompletion;

@protocol GMAEncodedSCARSignalsReader<NSObject>
- (void)getSCARSignals: (NSArray<UADSScarSignalParameters *>*) signalParameters
            completion: (UADSGMAEncodedSignalsCompletion *)completion;
@end


/**
   Extends the logic of @b GMAScarSignalsReader by providing encoding returned value into a json string.
 */
@interface GMASCARSignalsReaderDecorator : NSObject<GMAEncodedSCARSignalsReader>
+ (instancetype)newWithSignalService: (id<GMASCARSignalsReader>)signalService;
@end

NS_ASSUME_NONNULL_END
