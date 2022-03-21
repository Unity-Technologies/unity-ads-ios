#import "UADSDeviceReaderWithPII.h"
#import "NSDictionary+Filter.h"
#import "NSDictionary+Merge.h"
#import "UADSDeviceInfoExcludeFieldsProvider.h"
#import "NSMutableDictionary + SafeOperations.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSDeviceReaderWithPII ()
@property (nonatomic, strong) id<UADSDeviceInfoReader>original;
@property (nonatomic, strong) id<UADSPIIDataProvider>dataProvider;
@property (nonatomic, strong) id<UADSJsonStorageReader>jsonStorage;
@property (nonatomic, strong) id<UADSPIIDataSelector>dataSelector;
@end

@implementation UADSDeviceReaderWithPII

+ (id<UADSDeviceInfoReader>)newWithOriginal: (id<UADSDeviceInfoReader>)original
                            andDataProvider: (id<UADSPIIDataProvider>)dataProvider
                         andPIIDataSelector: (id<UADSPIIDataSelector>)dataSelector
                             andJsonStorage: (id<UADSJsonStorageReader>)jsonStorage; {
    UADSDeviceReaderWithPII *decorator = [UADSDeviceReaderWithPII new];

    decorator.original = original;
    decorator.jsonStorage = jsonStorage;
    decorator.dataProvider = dataProvider;
    decorator.dataSelector = dataSelector;
    return decorator;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSDictionary *originalDictionary = [self.original getDeviceInfoForGameMode: mode];
    UADSPIIDecisionData *decision = self.dataSelector.whatToDoWithPII;

    switch (decision.resultType) {
        case kUADSPIIDataSelectorResultInclude:
            return [self piiAttributesFromStorage: decision
                                      andOriginal: originalDictionary];


        case kUADSPIIDataSelectorResultUpdate:
            return [self piiAttributesFromDevice: decision
                                     andOriginal: originalDictionary];

        case kUADSPIIDataSelectorResultExclude:
            return originalDictionary;
    }
    return originalDictionary;
}

- (NSDictionary *)piiAttributesFromDevice: (UADSPIIDecisionData *)decisionData
                              andOriginal: (NSDictionary *)originalInfo  {
    NSMutableDictionary *mDeviceInfo = [NSMutableDictionary new];

    if (decisionData.updateVendorID) {
        mDeviceInfo[decisionData.vendorIDKey] = self.dataProvider.vendorID;
    }

    if (decisionData.updateAdvertisingTrackingId) {
        mDeviceInfo[decisionData.advertisingTrackingIdKey] = self.dataProvider.advertisingTrackingID;
    }

    [mDeviceInfo uads_setValueIfNotNil: decisionData.userNonBehavioralFlag
                                forKey: decisionData.userNonBehavioralFlagKey];

    return [originalInfo uads_newdictionaryByMergingWith: mDeviceInfo];
}

- (NSDictionary *)piiAttributesFromStorage: (UADSPIIDecisionData *)decisionData
                               andOriginal: (NSDictionary *)originalInfo {
    return [originalInfo uads_newdictionaryByMergingWith: decisionData.attributes];
}

@end
