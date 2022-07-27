#import <Foundation/Foundation.h>
#ifndef UADSDeviceInfoStorageKeysProvider_h
#define UADSDeviceInfoStorageKeysProvider_h

@protocol UADSDeviceInfoStorageKeysProvider
- (NSArray< NSString *> *)topLevelKeysToInclude;
- (NSArray< NSString *> *)keysToReduce;
- (NSArray< NSString *> *)keysToExclude;
@end

#endif /* UADSDeviceInfoStorageKeysProvider_h */
