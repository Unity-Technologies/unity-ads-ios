
#import <XCTest/XCTest.h>
#import "UADSDynamicLibLoader.h"

@interface QuartzCoreLoaderMock : UADSDynamicLibLoader
@end

@implementation QuartzCoreLoaderMock

+ (NSString *)frameworkName {
    return @"QuartzCore";
}

+ (NSString *)classNameForCheck {
    return  @"CALayer";
}

@end

@interface UnknownLoaderMock : UADSDynamicLibLoader
@end

@implementation UnknownLoaderMock


+ (NSString *)frameworkName {
    return @"frameworkName";
}

+ (NSString *)classNameForCheck {
    return  @"classNameForCheck";
}

@end

@interface DynamicLibLoaderTests: XCTestCase

@end

@implementation DynamicLibLoaderTests

- (void)test_returns_not_loaded_state {
    XCTAssertEqual(QuartzCoreLoaderMock.frameworkState, kUADSDynamicLibLoaderStateNotLoaded);
}

- (void)test_loads_framework_and_change_state {
    XCTAssertEqual([QuartzCoreLoaderMock loadFrameworkIfNotLoaded], kUADSDynamicLibLoaderStateLoaded);
    XCTAssertEqual([QuartzCoreLoaderMock loadFrameworkIfNotLoaded], kUADSDynamicLibLoaderStateLoaded);
    XCTAssertEqual(QuartzCoreLoaderMock.frameworkState, kUADSDynamicLibLoaderStateLoaded);
    [QuartzCoreLoaderMock close];
    
}

- (void)test_closing {
    XCTAssertEqual([QuartzCoreLoaderMock loadFrameworkIfNotLoaded], kUADSDynamicLibLoaderStateLoaded);
    [QuartzCoreLoaderMock close];
    XCTAssertEqual(QuartzCoreLoaderMock.frameworkState, kUADSDynamicLibLoaderStateNotLoaded);
    XCTAssertEqual([QuartzCoreLoaderMock loadFrameworkIfNotLoaded], kUADSDynamicLibLoaderStateLoaded);
    
}
- (void)test_fails_to_download_library_changes_the_state {
    XCTAssertEqual([UnknownLoaderMock loadFrameworkIfNotLoaded], kUADSDynamicLibLoaderStateFailed);
    XCTAssertEqual(UnknownLoaderMock.frameworkState, kUADSDynamicLibLoaderStateFailed);
}

- (void)test_inheritance_doesnt_share_common_state {
    [QuartzCoreLoaderMock loadFrameworkIfNotLoaded];
    [UnknownLoaderMock loadFrameworkIfNotLoaded];
    XCTAssertEqual(QuartzCoreLoaderMock.frameworkState, kUADSDynamicLibLoaderStateLoaded);
    XCTAssertEqual(UnknownLoaderMock.frameworkState, kUADSDynamicLibLoaderStateFailed);
}

@end
