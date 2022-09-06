#import "UADSWebViewURLBuilder.h"
#import "USRVBodyJSONCompressor.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "NSDictionary+JSONString.h"
#import "UADSTools.h"

@interface UADSWebViewURLBuilder ()
@property (nonatomic, copy) NSString *baseURLString;
@property (nonatomic, copy) NSDictionary *queryAttributes;
@property (nonatomic, copy) NSDictionary *experiments;
@property (nonatomic, strong) id<USRVStringCompressor> compressor;
@end

@implementation UADSWebViewURLBuilder
+ (instancetype)newWithBaseURL: (NSString *)base
            andQueryAttributes: (NSDictionary *)attributes
            andExperimentsJSON: (NSDictionary *)experiments {
    UADSWebViewURLBuilder *builder = [UADSWebViewURLBuilder new];

    builder.baseURLString = base;
    builder.queryAttributes = attributes ? : @{};
    builder.experiments = experiments ? : @{};
    builder.compressor = [USRVBodyJSONCompressor defaultURLEncoded];
    return builder;
}

+ (instancetype)newWithBaseURL: (NSString *)base andConfiguration: (USRVConfiguration *)config {
    NSMutableDictionary *queryAttributes = [NSMutableDictionary new];

    [queryAttributes uads_setValueIfNotNil: @"ios"
                                    forKey: @"platform"];
    [queryAttributes uads_setValueIfNotNil: config.webViewUrl
                                    forKey: @"origin"];
    [queryAttributes uads_setValueIfNotNil: config.webViewVersion
                                    forKey: @"version"];

    [queryAttributes uads_setValueIfNotNil: uads_bool_to_string(config.enableNativeMetrics)
                                    forKey: @"isNativeCollectingMetrics"];

    NSDictionary *experiments = config.experiments.isForwardExperimentsToWebViewEnabled ? config.experiments.json : @{};

    return [self newWithBaseURL: base
             andQueryAttributes: queryAttributes
             andExperimentsJSON: experiments];
}

- (nonnull NSString *)baseURL {
    return [_baseURLString stringByAppendingString: self.combinedAttributes.uads_queryString];
}

- (NSDictionary *)combinedAttributes {
    NSMutableDictionary *mAttributes = [NSMutableDictionary dictionaryWithDictionary: self.queryAttributes];

    if (!self.experiments.uads_isEmpty) {
        NSString *query = [self.compressor compressedIntoString: self.experiments];

        [mAttributes uads_setValueIfNotNil: query
                                    forKey: @"experiments"];
    }

    return mAttributes;
}

@end
