#import "GADQueryInfoBridge.h"
#import "NSInvocation+Convenience.h"
#import "NSError+UADSError.h"
#import "NSPrimitivesBox.h"

#define QUERY_KEY             @"query"
#define REQUEST_ID_KEY        @"requestIdentifier"
#define QUERY_DICTIONARY_KEY  @"queryDictionary"
#define SOURCE_DICTIONARY_KEY @"sourceQueryDictionary"
#define CREATE_SELECTOR       @"createQueryInfoWithRequest:adFormat:completionHandler:"

@implementation GADQueryInfoBridge

+ (NSArray<NSString *> *)requiredSelectors {
    return @[CREATE_SELECTOR];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[QUERY_KEY,
             REQUEST_ID_KEY,
             QUERY_DICTIONARY_KEY,
             SOURCE_DICTIONARY_KEY];
}

+ (NSString *)className {
    return @"GADQueryInfo";
}

- (NSString *_Nullable)query {
    return [self valueForKey: QUERY_KEY];
}

- (NSString *_Nullable)requestIdentifier {
    return [self valueForKey: REQUEST_ID_KEY];
}

- (NSDictionary *_Nullable)queryDictionary {
    return [self valueForKey: QUERY_DICTIONARY_KEY];
}

- (NSDictionary *_Nullable)sourceQueryDictionary {
    return [self valueForKey: SOURCE_DICTIONARY_KEY];
}

+ (void)createQueryInfo: (GADRequestBridge *)request
                 format: (GADQueryInfoAdType)type
             completion: (GADQueryInfoBridgeCompletion *)completion {
    id handler = ^(id queryInfo, NSError *error) {
        if (error) {
            [completion error: error];
            return;
        }

        if (queryInfo) {
            GADQueryInfoBridge *bridge = [GADQueryInfoBridge getProxyWithObject: queryInfo];
            [completion success: bridge];
            return;
        }
    };

    NSPrimitivesBox *typeWrapped = [NSPrimitivesBox newWithBytes: &type
                                                        objCType: @encode(GADQueryInfoAdType)];

    [NSInvocation uads_invokeUsingMethod: CREATE_SELECTOR
                               classType: [self getClass]
                                  target: nil
                                    args: @[request, typeWrapped, handler]];
}

@end
