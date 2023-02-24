#import <XCTest/XCTest.h>
#import "UADSBannerViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSBannerViewDelegateMock : NSObject <UADSBannerViewDelegate>
@property (nonatomic, strong) NSArray<UADSBannerView *> *succeedBanners;
@property (nonatomic, strong) NSArray<UADSBannerView *> *failedBanners;
@property (nonatomic, strong) NSArray<UADSBannerView *> *clickedBanners;
@property (nonatomic, strong) NSArray<UADSBannerView *> *leaveAppBanners;
@property (nonatomic, strong) NSArray<NSNumber *> *errorCodes;
@property (nonatomic, strong) NSArray<NSString *> *errorMessages;
@property (nonatomic, strong, readwrite) XCTestExpectation *expectation;
@end

NS_ASSUME_NONNULL_END


