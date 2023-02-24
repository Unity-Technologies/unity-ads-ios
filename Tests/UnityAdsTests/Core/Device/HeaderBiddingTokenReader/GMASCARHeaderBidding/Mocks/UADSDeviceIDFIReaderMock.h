#import <Foundation/Foundation.h>
#import "UADSDeviceIDFIReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceIDFIReaderMock : NSObject <UADSDeviceIDFIReader>

@property (nonatomic) NSString* expectedIdfi;

@end

NS_ASSUME_NONNULL_END
