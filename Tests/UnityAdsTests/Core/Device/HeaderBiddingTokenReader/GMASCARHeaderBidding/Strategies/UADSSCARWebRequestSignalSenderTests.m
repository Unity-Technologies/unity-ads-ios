#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderSCARSignalsConfig.h"
#import "UADSSCARHeaderBiddingFetchSendStrategyFactory.h"
#import "UADSConfigurationReaderMock.h"
#import "UADSSCARWebRequestSignalSender.h"
#import "USRVSdkProperties.h"
#import "UADSDeviceIDFIReaderMock.h"
#import "WebRequestFactoryMock.h"
#import "UADSSCARSignalIdentifiers.h"
#import "NSMutableDictionary+SafeOperations.h"

@interface UADSSCARWebRequestSignalSenderTests : XCTestCase
@property (nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig* configMock;
@property (nonatomic, strong) UADSConfigurationCRUDBase* configurationReader;
@property (nonatomic, strong) UADSSCARWebRequestSignalSender* signalSender;
@property (nonatomic, strong) UADSDeviceIDFIReaderMock* idfiReaderMock;
@property (nonatomic, strong) WebRequestFactoryMock* requestFactoryMock;

@end

@implementation UADSSCARWebRequestSignalSenderTests

- (void)setUp {
    _signalSender = [UADSSCARWebRequestSignalSender new];
    _configMock = [UADSHeaderBiddingTokenReaderSCARSignalsConfig new];
    _configurationReader = [UADSConfigurationCRUDBase new];
    _idfiReaderMock = [UADSDeviceIDFIReaderMock new];
    _requestFactoryMock = [WebRequestFactoryMock new];
    
    _configMock.configurationReader = _configurationReader;
    _configMock.idfiReader = _idfiReaderMock;
    _configMock.requestFactory = _requestFactoryMock;
    _signalSender.config = _configMock;
    _idfiReaderMock.expectedIdfi = @"idfi";
}

- (void)test_send_valid_signals_and_valid_uuid {
    [self checkSentRequestValuesWithRewardedValue:@"rewarded" interstitialValue:@"interstitial" uuidValue:@"uuid"];
}

- (void)test_send_one_valid_rv_signal_and_valid_uuid {
    [self checkSentRequestValuesWithRewardedValue:@"rewarded" interstitialValue:nil uuidValue:@"uuid"];
}

- (void)test_send_one_valid_int_signal_and_valid_uuid {
    [self checkSentRequestValuesWithRewardedValue:nil interstitialValue:@"interstitial" uuidValue:@"uuid"];
}

- (void)test_send_nil_signals_and_valid_uuid {
    [self checkNoSentRequestValuesWithRewardedValue:nil interstitialValue:nil uuidValue:@"uuid"];
}

- (void)test_send_valid_signals_and_nil_uuid {
    [self checkNoSentRequestValuesWithRewardedValue:@"rewarded" interstitialValue:@"interstitial" uuidValue:nil];
}

- (void)test_send_valid_signals_and_empty_uuid {
    [self checkNoSentRequestValuesWithRewardedValue:@"rewarded" interstitialValue:@"interstitial" uuidValue:@""];
}

- (void)test_send_nil_signal_reference_and_valid_uuid {
    [self.signalSender sendSCARSignalsWithUUIDString:@"uuid" signals:nil];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 0);
}

- (void)checkSentRequestValuesWithRewardedValue:(NSString*)rewardedValue interstitialValue:(NSString*)interstitialValue uuidValue:(NSString*)uuidValue {
    NSMutableDictionary* signals = [NSMutableDictionary new];
    [signals uads_setValueIfNotNil:rewardedValue forKey:UADSScarRewardedSignal];
    [signals uads_setValueIfNotNil:interstitialValue forKey:UADSScarInterstitialSignal];
    
    [self.signalSender sendSCARSignalsWithUUIDString:uuidValue signals:signals];
    
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);
    id<USRVWebRequest> mockRequest = self.requestFactoryMock.createdRequests[0];
    
    NSDictionary* mockRequestBodyDictionary = [self stringToDictionary:mockRequest.body];
    XCTAssertEqualObjects(mockRequestBodyDictionary[UADSScarUUIDKey], uuidValue);
    XCTAssertEqualObjects(mockRequestBodyDictionary[UADSScarRewardedKey], rewardedValue);
    XCTAssertEqualObjects(mockRequestBodyDictionary[UADSScarInterstitialKey], interstitialValue);
    XCTAssertEqualObjects(mockRequestBodyDictionary[UADSScarIdfiKey], _idfiReaderMock.expectedIdfi);
}

- (void)checkNoSentRequestValuesWithRewardedValue:(NSString*)rewardedValue interstitialValue:(NSString*)interstitialValue uuidValue:(NSString*)uuidValue {
    NSMutableDictionary* signals = [NSMutableDictionary new];
    [signals uads_setValueIfNotNil:rewardedValue forKey:UADSScarRewardedSignal];
    [signals uads_setValueIfNotNil:interstitialValue forKey:UADSScarInterstitialSignal];
    
    [self.signalSender sendSCARSignalsWithUUIDString:uuidValue signals:signals];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 0);
}

- (NSDictionary*)stringToDictionary:(NSString*)stringValue {
    NSData* data = [stringValue dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: data
                                                                     options: kNilOptions
                                                                       error: &error];
    return dictionary;
}

@end
