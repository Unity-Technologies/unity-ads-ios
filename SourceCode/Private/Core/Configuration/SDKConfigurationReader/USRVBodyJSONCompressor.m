#import "USRVBodyURLEncodedCompressorDecorator.h"
#import "NSDictionary+JSONString.h"
#import "USRVBodyJSONCompressor.h"

@implementation USRVBodyJSONCompressor


- (nonnull NSString *)compressedIntoString: (nonnull NSDictionary *)dictionary {
    return dictionary.uads_jsonEncodedString;
}

+ (id<USRVStringCompressor>)defaultURLEncoded; {
    USRVBodyJSONCompressor *original = [USRVBodyJSONCompressor new];

    return [USRVBodyURLEncodedCompressorDecorator decorateOriginal: original];
}

@end
