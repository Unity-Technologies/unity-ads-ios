#import "GMAAdLoaderStrategy.h"
#import <XCTest/XCTest.h>
#import "GMAError.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMAAdLoaderStrategy (SyncCategory)

- (void)loadSuccessSyncWithTestCase: (XCTestCase *)testCase
                        andMetaData: (GMAAdMetaData *)meta
               andSuccessCompletion: (UADSSuccessCompletion)completion;

- (void)loadSyncWithTestCase: (XCTestCase *)testCase
                 andMetaData: (GMAAdMetaData *)meta
               andCompletion: (void (^)(id _Nullable obj))completion
             errorCompletion: (void (^)(GMAError *))errorCompletion;

- (void)loadErrorSyncWithTestCase: (XCTestCase *)testCase
                      andMetaData: (GMAAdMetaData *)meta
               andErrorCompletion: (void (^)(GMAError *))errorCompletion;
@end

NS_ASSUME_NONNULL_END
