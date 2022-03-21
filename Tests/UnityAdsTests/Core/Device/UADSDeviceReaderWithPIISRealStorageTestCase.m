#import "UADSDeviceReaderWithPIITestCase.h"
#import "USRVStorageManager.h"

@interface UADSDeviceReaderWithPIISRealStorageTestCase : UADSDeviceReaderWithPIITestCase
@property (nonatomic, strong) id<UADSJsonStorageReader> jsonStorage;
@end

@implementation UADSDeviceReaderWithPIISRealStorageTestCase

- (void)setUp {
    [super setUp];
    [self.privateStorage clearStorage];
    [self.privateStorage initData];
}

- (id<UADSJsonStorageReader>)getStorage {
    return self.privateStorage;
}

- (USRVStorage *)privateStorage {
    return [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];
}

- (void)saveExpectedContentToJSONStorage: (NSDictionary *)content {
    for (NSString *key in content.allKeys) {
        [self.privateStorage set: key
                           value : content[key]];
    }
}

@end
