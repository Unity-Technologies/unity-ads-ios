#import "UnityAdsShowDelegate.h"
#import <XCTest/XCTest.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnityAdsShowDelegateMock : NSObject<UnityAdsShowDelegate>
@property (nonatomic, strong) NSArray<NSString *>* clickedPlacements;
@property (nonatomic, strong) NSArray<NSString *>* completedPlacements;
@property (nonatomic, strong) NSArray<NSString *>* startedPlacements;
@property (nonatomic, strong) NSArray<NSString *>* failedPlacements;
@property (nonatomic, strong) NSArray<NSNumber *>* failedReasons;
@property (nonatomic, strong, readwrite) XCTestExpectation *expectation;
@end

NS_ASSUME_NONNULL_END
