

@interface USRVApiRequest : NSObject

+ (NSArray<NSArray<NSString*>*> *)getHeadersArray:(NSDictionary<NSString*,NSString*> *)headersMap;
+ (NSDictionary<NSString*,NSArray*> *)getHeadersMap:(NSArray *)headers;

@end
