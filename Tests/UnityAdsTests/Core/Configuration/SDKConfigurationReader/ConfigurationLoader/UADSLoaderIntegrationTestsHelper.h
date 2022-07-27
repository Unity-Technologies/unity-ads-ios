#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface UADSLoaderIntegrationTestsHelper : NSObject
- (void)validateURLofRequest: (NSString *)urlString
        withExpectedHostHame: (NSString *)hostName
          andExpectedQueries: (NSDictionary *)queryAttributes;
- (NSDictionary *)successPayload;
- (NSDictionary *)successPayloadPrivacy;
- (NSDictionary *)successPayloadMissedData;
- (NSDictionary *)legacyFlowQueries;
- (void)validateURLOfRequest: (NSString *)urlString withExpectedCompressedKeys: (NSArray *)expectedKeys;
@end

NS_ASSUME_NONNULL_END
