#import "GMAWebViewEvent.h"
#import <Foundation/Foundation.h>
#import "USRVWebViewAppMock.h"
#import "UADSGenericCompletion.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMATestsHelper : NSObject
@property (nonatomic, strong) USRVWebViewAppMock *webViewMock;

- (void)install;
- (void)clear;
- (void)emulateIsAvailableCall: (UADSSuccessCompletion)completion;
- (void)emulateGetVersionCall: (UADSSuccessCompletion)completion;
- (void)emulateGetScarSignal: (NSString *)placementId
                    adFormat: (NSString *)adFormat
                    testCase: (XCTestCase *)testCase
              expectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents;

- (void)emulateLoadWithParams: (NSArray *)params
                     testCase: (XCTestCase *)testCase
               expectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents;
- (void)emulateShowWithParams: (NSArray *)params
                     testCase: (XCTestCase *)testCase
               expectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents;
@end

NS_ASSUME_NONNULL_END
