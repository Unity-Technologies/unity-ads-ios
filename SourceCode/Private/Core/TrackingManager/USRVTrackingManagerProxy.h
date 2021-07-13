@interface USRVTrackingManagerProxy : NSObject
+ (USRVTrackingManagerProxy *)sharedInstance;
- (BOOL)                      available;
- (void)                      requestTrackingAuthorization;
- (NSUInteger)                trackingAuthorizationStatus;
@end
