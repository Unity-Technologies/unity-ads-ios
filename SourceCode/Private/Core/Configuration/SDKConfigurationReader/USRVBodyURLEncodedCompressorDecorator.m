#import "USRVBodyURLEncodedCompressorDecorator.h"


@interface USRVBodyURLEncodedCompressorDecorator ()
@property (nonatomic, strong) id<USRVStringCompressor> original;
@end

@implementation USRVBodyURLEncodedCompressorDecorator

+ (instancetype)decorateOriginal: (id<USRVStringCompressor>)original {
    USRVBodyURLEncodedCompressorDecorator *decorator = [USRVBodyURLEncodedCompressorDecorator new];

    decorator.original = original;
    return decorator;
}

- (nonnull NSString *)compressedIntoString: (nonnull NSDictionary *)dictionary {
    NSString *compressedString = [self.original compressedIntoString: dictionary];

    NSString *urlEncoded = [compressedString stringByAddingPercentEncodingWithAllowedCharacters: NSCharacterSet.URLHostAllowedCharacterSet];

    //Replace + because on the backend side they are treated as spaces
    return [urlEncoded stringByReplacingOccurrencesOfString: @"+"
                                                 withString: @"%2B"];
}

@end
