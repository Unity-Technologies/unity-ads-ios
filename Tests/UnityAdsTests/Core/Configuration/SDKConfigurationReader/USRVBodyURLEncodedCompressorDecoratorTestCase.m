#import <XCTest/XCTest.h>
#import "USRVBodyCompressorMock.h"
#import "USRVBodyURLEncodedCompressorDecorator.h"

@interface USRVBodyURLEncodedCompressorDecoratorTestCase : XCTestCase
@property (nonatomic, strong) USRVBodyCompressorMock *compressorMock;
@end

@implementation USRVBodyURLEncodedCompressorDecoratorTestCase

- (void)setUp {
    self.compressorMock = [USRVBodyCompressorMock new];
}

- (void)test_replaces_pluses_with_proper_values {
    NSString *originalString = @"/abc+123+";

    self.compressorMock.expectedString = originalString;
    NSString *resultString = [self.sut compressedIntoString: @{}];

    NSString *expectedString = @"%2Fabc%2B123%2B";

    XCTAssertEqualObjects(resultString, expectedString);
}

- (id<USRVStringCompressor>)sut {
    return [USRVBodyURLEncodedCompressorDecorator decorateOriginal: self.compressorMock];
}

@end
