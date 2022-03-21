#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSPIIDataSelectorResult) {
    kUADSPIIDataSelectorResultInclude,
    kUADSPIIDataSelectorResultExclude,
    kUADSPIIDataSelectorResultUpdate,
};

@interface UADSPIIDecisionData : NSObject
@property (nonatomic, assign) UADSPIIDataSelectorResult resultType;
@property (nonatomic, strong, readonly) NSDictionary *attributes;

+ (instancetype)newIncludeWithAttributes: (NSDictionary *)attributes;
+ (instancetype)       newExclude;
+ (instancetype)newUpdateWithAttributes: (NSDictionary *)attributes;
- (instancetype)decisionAppending: (NSDictionary *)attributes;
- (NSArray *)          keys;
- (BOOL)               updateVendorID;
- (BOOL)               updateAdvertisingTrackingId;
- (NSString *)         advertisingTrackingIdKey;
- (NSString *)         vendorIDKey;
- (NSNumber *_Nullable)userNonBehavioralFlag;
- (NSString *)         userNonBehavioralFlagKey;
@end

NS_ASSUME_NONNULL_END
