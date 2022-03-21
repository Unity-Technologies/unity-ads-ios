
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol USRVDataCompressor <NSObject>

- (NSData *)compressedIntoData: (NSDictionary *)dictionary;

@end

@interface USRVDataGzipCompressor : NSObject <USRVDataCompressor>

@end

NS_ASSUME_NONNULL_END
