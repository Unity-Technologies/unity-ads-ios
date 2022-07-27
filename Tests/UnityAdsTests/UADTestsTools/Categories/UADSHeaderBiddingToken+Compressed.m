#import "UADSHeaderBiddingToken+Compressed.h"
#import "NSData+GZIP.h"
#import "NSData+JSONSerialization.h"

@implementation UADSHeaderBiddingToken (Compressed)
- (NSDictionary *)tokenDictionary {
    NSString *compressed = [[self.value componentsSeparatedByString: @":"] lastObject];

    if (!compressed) {
        return nil;
    }

    NSData *compressedData = [[NSData alloc] initWithBase64EncodedString: compressed
                                                                 options: 0];

    return compressedData.uads_gunzippedData.uads_jsonRepresentation;
}

@end
