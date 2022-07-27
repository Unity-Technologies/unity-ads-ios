#import <Foundation/Foundation.h>


@interface NSData (GZIP)

- (nullable NSData *)uads_gzippedDataWithCompressionLevel: (float)level;
- (nullable NSData *)uads_gzippedData;
- (nullable NSData *)uads_gunzippedData;
- (BOOL)             uads_isGzippedData;
@end
