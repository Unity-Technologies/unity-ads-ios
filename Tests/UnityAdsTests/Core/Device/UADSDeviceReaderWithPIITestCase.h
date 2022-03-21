#import <XCTest/XCTest.h>
#import "UADSJsonStorageReaderMock.h"
#ifndef UADSDeviceReaderWithPIITestCase_h
#define UADSDeviceReaderWithPIITestCase_h

@interface UADSDeviceReaderWithPIITestCase : XCTestCase
- (id<UADSJsonStorageReader>)getStorage;
- (void)                     saveExpectedContentToJSONStorage: (NSDictionary *)content;
- (NSString *)               piiKey;
@end

#endif /* UADSDeviceReaderWithPIITestCase_h */
