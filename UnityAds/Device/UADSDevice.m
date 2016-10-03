@import UIKit;
@import AdSupport;
@import AVFoundation;
@import CoreTelephony;

#import <sys/utsname.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

#import "UnityAds.h"
#import "UADSDevice.h"
#import "UADSConnectivityUtils.h"

static CTTelephonyNetworkInfo *uadsTelephonyInfo;

@implementation UADSDevice

+ (void)initCarrierUpdates {
    uadsTelephonyInfo = [CTTelephonyNetworkInfo new];
    uadsTelephonyInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier) { };
}

+ (NSString *)getOsVersion {
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    return osVersion;
}

+ (NSString *)getModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([UADSDevice isSimulator]) {
        model = [[UIDevice currentDevice] model];
    }

    return model;
}

+ (BOOL)isSimulator {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([model isEqualToString:@"x86_64"] || [model isEqualToString:@"i386"]) {
        return true;
    }
    
    return false;
}

+ (NSInteger)getScreenLayout {
    // UIDeviceOrientation
    return [[UIDevice currentDevice] orientation];
}

+ (NSString *)getAdvertisingTrackingId {
    NSUUID *identifier = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    return [identifier UUIDString];
}

+ (BOOL)isLimitTrackingEnabled {
    // Note that isAdvertisingTrackingEnabled == !isLimitTrackingEnabled
    return ![ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled;
}

+ (BOOL)isUsingWifi {
    BOOL retValue = NO;
    if ([UADSConnectivityUtils getNetworkStatus] == ReachableViaWiFi) {
        retValue = YES;
    }
    return retValue;
}

+ (NSInteger)getNetworkType {
    return [UADSConnectivityUtils getNetworkType];
}

+ (NSString *)getNetworkOperator {
    NSString *networkOperator = uadsTelephonyInfo.subscriberCellularProvider.mobileCountryCode;
    networkOperator = [networkOperator stringByAppendingString:uadsTelephonyInfo.subscriberCellularProvider.mobileNetworkCode];
    
    return networkOperator;
;
}

+ (NSString *)getNetworkOperatorName {
    return uadsTelephonyInfo.subscriberCellularProvider.carrierName;

}

+ (float)getScreenScale {
    return [[UIScreen mainScreen] scale];
}

+ (NSNumber *)getScreenWidth {
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    return [NSNumber numberWithFloat:rect.size.width];
}

+ (NSNumber *)getScreenHeight {
    CGRect rect = [UIScreen mainScreen].applicationFrame;
    return [NSNumber numberWithFloat:rect.size.height];;
}

+ (BOOL)isActiveNetworkConnected {
    if ([UADSConnectivityUtils getNetworkStatus] != NotReachable) {
        return YES;
    }
    return NO;
}

+ (NSString *)getUniqueEventId {
    return [[NSUUID UUID] UUIDString];;
}

+ (BOOL)isWiredHeadsetOn {
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

+ (NSString *)getTimeZone:(BOOL) daylightSavingTime {
    NSDate *currentDate = [NSDate date];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    
    if (!daylightSavingTime && [timeZone isDaylightSavingTimeForDate:currentDate]) {
        NSInteger secondsFromGMT = [timeZone secondsFromGMTForDate:currentDate];

        NSTimeInterval timeInterval = [timeZone daylightSavingTimeOffsetForDate:currentDate];
        secondsFromGMT -= timeInterval;

        timeZone = [NSTimeZone timeZoneForSecondsFromGMT:secondsFromGMT];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    // e.g. +0200
    [dateFormatter setDateFormat:@"ZZZ"];
    [dateFormatter setTimeZone:timeZone];

    return [dateFormatter stringFromDate:currentDate];
}

+ (NSString *)getPreferredLocalization {
    NSString* preferredLocalization = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    preferredLocalization = [preferredLocalization stringByReplacingOccurrencesOfString:@"-" withString:@"_"];

    return preferredLocalization;
}

+ (float)getOutputVolume {
    return [[AVAudioSession sharedInstance] outputVolume];;
}

+ (float)getScreenBrightness {
    return [UIScreen mainScreen].brightness;
}

+ (NSNumber *)getFreeSpaceInKilobytes {
    unsigned long long freeSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    return [NSNumber numberWithUnsignedLongLong:freeSpace / 1024];
}

+ (NSNumber *)getTotalSpaceInKilobytes {
    unsigned long long totalSpace = [[[[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil] objectForKey:NSFileSystemSize] unsignedLongLongValue];
    return [NSNumber numberWithUnsignedLongLong:totalSpace/1024];
}

+ (float)getBatteryLevel {
    return [UIDevice currentDevice].batteryLevel;
}

+ (NSInteger)getBatteryStatus {
    UIDeviceBatteryState currentState = [UIDevice currentDevice].batteryState;
    return currentState;
}

+ (NSNumber *)getTotalMemoryInKilobytes {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        UADSLogDebug(@"Failed to fetch vm statistics");
    }
    
    unsigned long long mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * (unsigned int)pagesize;
    unsigned long long mem_free = vm_stat.free_count * (unsigned long long)pagesize;
    unsigned long long mem_total = mem_used + mem_free;
    UADSLogDebug(@"used: %llu free: %llu total: %llu", mem_used, mem_free, mem_total);
    
    return [NSNumber numberWithUnsignedLongLong:(unsigned long long)mem_total/1024];
}


+ (NSNumber *)getFreeMemoryInKilobytes {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        UADSLogDebug(@"Failed to fetch vm statistics");
    }
    
    unsigned long long mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * (unsigned int)pagesize;
    unsigned long long mem_free = vm_stat.free_count * (unsigned long long)pagesize;
    UADSLogDebug(@"used: %llu free: %llu", mem_used, mem_free);
    
    return [NSNumber numberWithLongLong:(unsigned long long)mem_free/1024];
}

+ (BOOL)isRooted {
#if !(TARGET_IPHONE_SIMULATOR)
    if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Applications/Cydia.app"]){
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/MobileSubstrate.dylib"]) {
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/bin/bash"]){
        return YES;
    } else if([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/sbin/sshd"]){
        return YES;
    } else if ([[NSFileManager defaultManager] fileExistsAtPath:@"/etc/apt"]){
        return YES;
    }
        
    NSError *error = nil;
    NSString *stringToBeWritten = @"Check if a device is jailbroken";
    [stringToBeWritten writeToFile:@"/private/jailbreak.txt" atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (!error) {
       //Device is jailbroken
       return YES;
    } else {
       [[NSFileManager defaultManager] removeItemAtPath:@"/private/jailbreak.txt" error:nil];
    }
#endif
    return NO;
}

+ (NSInteger)getUserInterfaceIdiom {
    return [[UIDevice currentDevice] userInterfaceIdiom];
}

@end

