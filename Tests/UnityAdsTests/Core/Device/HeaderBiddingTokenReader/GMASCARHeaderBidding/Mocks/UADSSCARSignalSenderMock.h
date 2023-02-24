#import <Foundation/Foundation.h>
#import "UADSSCARSignalSender.h"
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface UADSSCARSignalSenderMockData : NSObject

@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, strong) UADSSCARSignals *signals;

-(instancetype)initWithUUIDString:(NSString*)uuidString signals:(UADSSCARSignals*)signals;

@end

@interface UADSSCARSignalSenderMock : NSObject <UADSSCARSignalSender>

@property (nonatomic) NSMutableArray<UADSSCARSignalSenderMockData*>* callHistory;
@property (nonatomic) XCTestExpectation* callExpectation;

@end

NS_ASSUME_NONNULL_END
