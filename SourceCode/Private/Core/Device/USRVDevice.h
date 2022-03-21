#import "USRVMuteSwitch.h"

@interface USRVDevice : NSObject
+ (void)      initCarrierUpdates;

+ (NSString *)getOsVersion;

+ (NSString *)getModel;

+ (BOOL)      isSimulator;

+ (NSInteger) getScreenLayout;

+ (NSString *)getAdvertisingTrackingId;

+ (BOOL)      isLimitTrackingEnabled;

+ (BOOL)      isUsingWifi;

+ (NSInteger) getNetworkType;

+ (NSString *)getNetworkOperator;

+ (NSString *)getNetworkOperatorName;

+ (NSString *)getNetworkCountryISO;
+ (NSString *)getNetworkCountryISOWithLocaleFallback;

+ (float)     getScreenScale;

+ (NSNumber *)getScreenWidth;

+ (NSNumber *)getScreenHeight;

+ (BOOL)      isActiveNetworkConnected;

+ (NSString *)getUniqueEventId;

+ (BOOL)      isWiredHeadsetOn;

+ (NSString *)getTimeZone: (BOOL)daylightSavingTime;

+ (NSInteger)            getTimeZoneOffset;

+ (NSString *)           getPreferredLocalization;

+ (float)                getOutputVolume;

+ (float)                getScreenBrightness;

+ (NSNumber *)           getFreeSpaceInKilobytes;

+ (NSNumber *)           getTotalSpaceInKilobytes;

+ (float)                getBatteryLevel;

+ (NSInteger)            getBatteryStatus;

+ (NSNumber *)           getTotalMemoryInKilobytes;

+ (NSNumber *)           getFreeMemoryInKilobytes;

+ (NSDictionary *)       getProcessInfo;

+ (BOOL)                 isRooted;

+ (NSInteger)            getUserInterfaceIdiom;

+ (NSArray<NSString *> *)getSensorList;

+ (NSString *)           getGLVersion;

+ (float)                getDeviceMaxVolume;

+ (NSUInteger)           getCPUCount;

+ (void)                 checkIsMuted;

+ (NSNumber *)           getUptime;

+ (NSNumber *)           getElapsedRealtime;

+ (NSString *)           getVendorIdentifier;

+ (NSString *)           getDeviceName;

+ (NSNumber *)           getSystemBootTime;

+ (NSArray<NSString *> *)getLocaleList;

+ (NSNumber *)           getCurrentUITheme;

+ (NSString *)           getWebViewUserAgent;

+ (NSNumber *)           currentTimeStamp;
+ (NSNumber *)           currentTimeStampInSeconds;
+ (BOOL)                 isAppInForeground;
@end
