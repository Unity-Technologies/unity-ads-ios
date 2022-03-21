#import <Foundation/Foundation.h>
#import "USRVStorage.h"
#import "UADSPIITrackingStatusReader.h"
#import "UADSTsiMetric.h"
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
- (NSArray *)     allExpectedKeys;
- (void)          setPIIDataToStorage;
- (void)         commitPrivacyMode: (UADSPrivacyMode)mode
                  andNonBehavioral: (BOOL)flag;
- (void)validateDataContains: (NSDictionary *)data allKeys: (NSArray *)keys;
- (NSDictionary *)          piiDecisionContentData;
- (NSDictionary *)piiDecisionContentDataWithUserBehavioral: (BOOL)flag;
- (void)saveExpectedContentToJSONStorage: (NSDictionary *)content;
- (NSArray *)expectedPrivacyModeKeysWitNonBehavioral: (BOOL)nonBehavioral;
- (void)setSMPPrivacyMode: (UADSPrivacyMode)mode;
- (NSArray <UADSMetric *> *)missedDataMetrics;
- (UADSMetric *)            tsiNoSessionIDMetrics;
- (UADSMetric *)            emergencyOffMetrics;
- (UADSMetric *)            infoCollectionLatencyMetrics;
- (UADSMetric *)            infoCompressionLatencyMetrics;
- (NSDictionary *)          expectedTags;
@end

NS_ASSUME_NONNULL_END
