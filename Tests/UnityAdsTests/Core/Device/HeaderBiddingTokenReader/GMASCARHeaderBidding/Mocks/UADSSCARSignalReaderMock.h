#import <Foundation/Foundation.h>
#import "UADSSCARSignalReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARSignalReaderMock : NSObject <UADSSCARSignalReader>

@property (nonatomic) int callHistoryCount;
@property (nonatomic) NSDictionary* signals;
@property (nonatomic) bool shouldAutoComplete;

- (void) triggerSignalCompletion;

@end

NS_ASSUME_NONNULL_END
