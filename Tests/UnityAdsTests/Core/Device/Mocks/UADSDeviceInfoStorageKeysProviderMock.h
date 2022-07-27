#import <Foundation/Foundation.h>
#import "UADSDeviceInfoStorageKeysProvider.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoStorageKeysProviderMock : NSObject<UADSDeviceInfoStorageKeysProvider>
@property (nonatomic, strong) NSArray< NSString *> *topLevelKeysToInclude;
@property (nonatomic, strong) NSArray< NSString *> *keysToReduce;
@property (nonatomic, strong) NSArray< NSString *> *keysToExclude;
@end

NS_ASSUME_NONNULL_END
