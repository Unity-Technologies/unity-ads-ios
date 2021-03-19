#import "UnityAdsLoadDelegate.h"
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityAdsLoadDelegateMock : NSObject<UnityAdsLoadDelegate>
@property (nonatomic, strong) NSArray<NSString *>* succeedPlacements;
@property (nonatomic, strong) NSArray<NSString *>* failedPlacements;
@property (nonatomic, strong) NSArray<NSNumber *>* errorCodes;
@property (nonatomic, strong) NSArray<NSString *>* errorMessages;
@property (nonatomic, strong, readwrite) XCTestExpectation *expectation;
@end

NS_ASSUME_NONNULL_END
