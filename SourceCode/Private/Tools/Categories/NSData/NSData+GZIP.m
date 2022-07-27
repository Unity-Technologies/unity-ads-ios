#import "NSData+GZIP.h"
#import <zlib.h>


#pragma clang diagnostic ignored "-Wcast-qual"


@implementation NSData (GZIP)

- (NSData *)uads_gzippedDataWithCompressionLevel: (float)level
{
    if (self.length == 0 || [self uads_isGzippedData]) {
        return self;
    }

    z_stream stream;

    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)self.length;
    stream.next_in = (Bytef *)(void *)self.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;

    static const NSUInteger ChunkSize = 16384;

    NSMutableData *output = nil;
    int compression = (level < 0.0f) ? Z_DEFAULT_COMPRESSION : (int)(roundf(level * 9));

    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK) {
        output = [NSMutableData dataWithLength: ChunkSize];

        while (stream.avail_out == 0) {
            if (stream.total_out >= output.length) {
                output.length += ChunkSize;
            }

            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }

    return output;
}

- (NSData *)uads_gzippedData
{
    return [self uads_gzippedDataWithCompressionLevel: -1.0f];
}

- (NSData *)uads_gunzippedData
{
    if (self.length == 0 || ![self uads_isGzippedData]) {
        return self;
    }

    z_stream stream;

    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.avail_in = (uint)self.length;
    stream.next_in = (Bytef *)self.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;

    NSMutableData *output = nil;

    if (inflateInit2(&stream, 47) == Z_OK) {
        int status = Z_OK;
        output = [NSMutableData dataWithCapacity: self.length * 2];

        while (status == Z_OK) {
            if (stream.total_out >= output.length) {
                output.length += self.length / 2;
            }

            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            status = inflate(&stream, Z_SYNC_FLUSH);
        }

        if (inflateEnd(&stream) == Z_OK) {
            if (status == Z_STREAM_END) {
                output.length = stream.total_out;
            }
        }
    }

    return output;
}

- (BOOL)uads_isGzippedData
{
    const UInt8 *bytes = (const UInt8 *)self.bytes;

    return (self.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}

@end
