@interface UADSBaseOptions : NSObject

@property (nonatomic, strong, readonly) NSDictionary* dictionary;
@property (nonatomic, readwrite) NSString* objectId;

- (instancetype)init;

@end
