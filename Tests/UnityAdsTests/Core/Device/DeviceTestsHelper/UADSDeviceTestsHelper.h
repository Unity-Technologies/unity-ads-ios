#import <Foundation/Foundation.h>
#import "USRVStorage.h"
#import "UADSPIITrackingStatusReader.h"
#import "UADSTsiMetric.h"
#import "UADSPrivacyLoader.h"
#import "UADSConfigurationLoader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceTestsHelper : NSObject
- (void)          commitPIPLSMetaData;
- (void)          commitPrivacyMetaData;
- (void)          commitGDPRMetaData;
- (void)          commitDataThatShouldBeFiltered;
- (void)          commitFrameworkData;
- (void)          commitAdapterData;
- (void)          commitWebViewPrivacyData;
- (void)          commitConfigurationData;
- (void)          clearAllStorages;
- (void)          setIDFI;
- (void)          commitAllTestData;
- (void)          commitUserDefaultsTestData;
- (USRVStorage *) privateStorage;
- (USRVStorage *) publicStorage;
- (NSString *)    idfiMockValue;
- (void)          setAnalyticSessionID;
- (void)          setAnalyticUserID;
- (NSString *)    analyticSessionMockValue;
- (NSString *)    analyticUserMockValue;
- (NSDictionary *)expectedMergedDataRealStorage;
- (NSArray *)     expectedKeysFromDefaultInfo;
- (NSArray *)     expectedKeysFromDefaultMinInfo;
- (NSArray *)     allExpectedKeys;
- (void)          setPIIDataToStorage;
- (void)         commitPrivacyMode: (UADSPrivacyMode)mode
                  andNonBehavioral: (BOOL)flag;
- (void)validateDataContains: (NSDictionary *)data allKeys: (NSArray *)keys;
- (NSDictionary *)          piiDecisionContentData;
- (void)saveExpectedContentToJSONStorage: (NSDictionary *)content;
- (NSArray *)expectedPrivacyModeKey;
- (void)setSMPPrivacyMode: (UADSPrivacyMode)mode;
- (NSArray <UADSMetric *> *)missedDataMetrics;
- (UADSMetric *)            tsiNoSessionIDMetrics;
- (UADSMetric *)            infoCollectionLatencyMetrics;
- (UADSMetric *)            infoCompressionLatencyMetrics;
- (UADSMetric *)            privacyRequestLatencyMetrics;
- (NSArray *)               allExpectedKeysFromMinInfo;
- (UADSMetric *)privacyRequestFailureWithReason: (UADSPrivacyLoaderError)reason;
- (UADSMetric *)configLatencyFailureMetricWithReason: (UADSConfigurationLoaderError)reason;
- (UADSMetric *)            configLatencySuccessMetric;
- (NSDictionary *)          retryTags;
@end

NS_ASSUME_NONNULL_END
