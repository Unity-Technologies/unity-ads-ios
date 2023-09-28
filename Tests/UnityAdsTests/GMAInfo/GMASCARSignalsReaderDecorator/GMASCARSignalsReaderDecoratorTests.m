#import <XCTest/XCTest.h>
#import "GMASCARSignalsReaderDecorator.h"
#import "GMASCARSignalsReaderMock.h"
#import "UADSTools.h"
#define EMPTY_ARRAY [NSArray new]

@interface GMASCARSignalsReaderDecoratorTests : XCTestCase
@property (nonatomic, strong) GMASCARSignalsReaderMock *readerMock;
@property (nonatomic, strong) GMASCARSignalsReaderDecorator *sut;
@end

@implementation GMASCARSignalsReaderDecoratorTests

- (void)setUp {
    _readerMock = [GMASCARSignalsReaderMock new];
    _sut = [GMASCARSignalsReaderDecorator newWithSignalService: _readerMock];
}

- (void)tearDown {
    _readerMock = nil;
    _sut = nil;
}

- (void)test_returns_empty_string_when_empty_dictionary_is_passed {
    __block NSString *returnedString;
    id completion = [self defaultCompletion:^(NSString *_Nullable string) {
        returnedString = string;
    }];

    [_sut getSCARSignals: EMPTY_ARRAY
              completion: completion];

    [_readerMock emulateReturnOfAnEmptyDictionary];
    XCTAssertEqualObjects(returnedString, kUADS_EMPTY_STRING);
}

- (void)test_returns_empty_string_when_nil_dictionary_is_passed {
    __block NSString *returnedString;
    id completion = [self defaultCompletion:^(NSString *_Nullable string) {
        returnedString = string;
    }];

    [_sut getSCARSignals: EMPTY_ARRAY
              completion: completion];

    [_readerMock emulateReturnOfNil];
    XCTAssertEqualObjects(returnedString, kUADS_EMPTY_STRING);
}

- (void)test_returns_encoded_non_empty_string {
    __block NSString *returnedString;
    id completion = [self defaultCompletion:^(NSString *_Nullable string) {
        returnedString = string;
    }];

    NSDictionary *testDictionary = @{
        @"key": @"value"
    };

    [_sut getSCARSignals: EMPTY_ARRAY
              completion: completion];


    [_readerMock emulateReturnOfADictionary: testDictionary];
    XCTAssertEqualObjects(returnedString, @"{\n  \"key\" : \"value\"\n}");
}

- (UADSGMAEncodedSignalsCompletion *)defaultCompletion: (UADSSuccessCompletion)completion {
    UADSErrorCompletion errorHandler =  ^(id<UADSError> error) {
        XCTFail("Don't expect error flow");
    };

    return [UADSGMAEncodedSignalsCompletion newWithSuccess: completion
                                                  andError: errorHandler];
}

@end
