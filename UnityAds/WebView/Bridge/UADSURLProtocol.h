

@interface UADSURLProtocol : NSURLProtocol

- (void)actOnJSONResults:(NSData *)jsonData invocationType:(NSString *)invocationType;

@end
