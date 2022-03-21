#import <XCTest/XCTest.h>
#import "UADSOverlayEventHandler.h"

@interface UADSOverlayEventHandlerMock : NSObject <UADSOverlayEventProtocol>
@property (nonatomic, copy) void (^ didFailToLoad)(UADSOverlayError, NSString *);
@property (nonatomic, copy) void (^ willStartPresentation)(void);
@property (nonatomic, copy) void (^ didFinishPresentation)(void);
@property (nonatomic, copy) void (^ willStartDismissal)(void);
@property (nonatomic, copy) void (^ didFinishDismissal)(void);

- (XCTestExpectation *)setFailCallbackWithExpectedError: (UADSOverlayError)expectedError;
- (XCTestExpectation *)setPresentationCallbacks;
- (XCTestExpectation *)setDismissalCallbacks;

@end
