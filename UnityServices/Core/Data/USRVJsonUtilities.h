NS_ASSUME_NONNULL_BEGIN

extern NSString * const USRVJsonUtilitiesErrorDomain;

typedef NS_ENUM(NSInteger, USRVJsonUtilitiesErrorCode) {
    USRVJsonUtilitiesErrorCodeInvalidJson,
    USRVJsonUtilitiesErrorCodeExceptionCaught,
    USRVJsonUtilitiesErrorCodeErrorCaught
};

@interface USRVJsonUtilities : NSObject

+ (NSData *)dataWithJSONObject:(id)obj options:(NSJSONWritingOptions)opt error:(NSError * _Nullable *)error;

@end

NS_ASSUME_NONNULL_END
