#import "UADSAbstractModuleDelegate.h"
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN
static NSString * const kUADSShowDelegateMockID = @"UADSShowDelegateMockID";

@interface UADSAbstractModuleDelegateMock: NSObject<UADSAbstractModuleDelegate>
@property (nonatomic, strong) NSString *uuidString;
@property (nonatomic, strong) NSArray<UADSInternalError *> *errors;
@property (nonatomic, strong) NSArray<NSString *> *placementIDs;
@property (nonatomic, strong) XCTestExpectation *expectation;
@end

NS_ASSUME_NONNULL_END
