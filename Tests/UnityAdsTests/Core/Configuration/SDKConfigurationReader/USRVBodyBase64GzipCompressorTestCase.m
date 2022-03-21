#import <XCTest/XCTest.h>
#import "USRVBodyBase64GzipCompressor.h"
#import "USRVDataGzipCompressor.h"

@interface USRVBodyBase64GzipCompressorTestCase : XCTestCase

@end

@implementation USRVBodyBase64GzipCompressorTestCase


- (void)test_compressor_returns_proper_string {
    NSString *resultString = [self.sut compressedIntoString: self.testDictionary];

    XCTAssertEqualObjects(resultString, @"H4sIAAAAAAAAE6tWyk6tVLJSKkvMKU1VqgUAv5wYPw8AAAA=");
}

- (id<USRVStringCompressor>)sut {
    return [USRVBodyBase64GzipCompressor newWithDataCompressor: [USRVDataGzipCompressor new]];
}

- (NSDictionary *)testDictionary {
    return @{
        @"key": @"value"
    };
}

@end
