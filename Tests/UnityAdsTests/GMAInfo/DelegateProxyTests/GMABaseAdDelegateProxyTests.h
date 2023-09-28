#import <XCTest/XCTest.h>
#import "GMADelegatesFactory.h"
#import "GMAWebViewEvent.h"
#import "USRVWebViewAppMock.h"
#import "UADSTimerFactoryMock.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMABaseAdDelegateProxyTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@property (nonatomic, strong) UADSTimerFactoryMock *timerFactoryMock;

- (id<GMADelegatesFactory>)delegatesFactory;
- (id)fakeAdObject;
- (void)validateExpectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents;
- (void)validateExpectedDefaultParamsInEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents;
@end

NS_ASSUME_NONNULL_END
