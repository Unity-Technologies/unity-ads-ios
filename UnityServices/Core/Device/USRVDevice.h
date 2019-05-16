

@interface USRVDevice : NSObject
+ (void) initCarrierUpdates;

+ (NSString *)getOsVersion;

+ (NSString *)getModel;

+ (BOOL)isSimulator;

+ (NSInteger)getScreenLayout;

+ (NSString *)getAdvertisingTrackingId;

+ (BOOL)isLimitTrackingEnabled;

+ (BOOL)isUsingWifi;

+ (NSInteger)getNetworkType;

+ (NSString *)getNetworkOperator;

+ (NSString *)getNetworkOperatorName;

+ (float)getScreenScale;

+ (NSNumber *)getScreenWidth;

+ (NSNumber *)getScreenHeight;

+ (BOOL)isActiveNetworkConnected;

+ (NSString *)getUniqueEventId;

+ (BOOL)isWiredHeadsetOn;

+ (NSString *)getTimeZone:(BOOL) daylightSavingTime;

+ (NSInteger)getTimeZoneOffset;

+ (NSString *)getPreferredLocalization;

+ (float)getOutputVolume;

+ (float)getScreenBrightness;

+ (NSNumber *)getFreeSpaceInKilobytes;

+ (NSNumber *)getTotalSpaceInKilobytes;

+ (float)getBatteryLevel;

+ (NSInteger)getBatteryStatus;

+ (NSNumber *)getTotalMemoryInKilobytes;

+ (NSNumber *)getFreeMemoryInKilobytes;

+ (NSDictionary *)getProcessInfo;

+ (BOOL)isRooted;

+ (NSInteger)getUserInterfaceIdiom;

+ (NSArray<NSString *>*)getSensorList;

+ (NSString *)getGLVersion;

+ (float)getDeviceMaxVolume;

+ (NSUInteger)getCPUCount;

@end
