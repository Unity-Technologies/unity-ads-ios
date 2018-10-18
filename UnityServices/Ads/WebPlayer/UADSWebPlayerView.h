#import <UIKit/UIKit.h>

@interface UADSWebPlayerView : UIView
- (instancetype)initWithFrame:(CGRect)frame viewId:(NSString*)viewId webPlayerSettings:(NSDictionary*)webPlayerSettings;
-(void)loadUrl:(NSString*)url;
-(void)loadData:(NSString*)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding;
-(void)loadData:(NSString*)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding baseUrl:(NSString *)baseUrl;
-(void)setWebPlayerSettings:(NSDictionary*)webPlayerSettings;
-(void)setEventSettings:(NSDictionary*)eventSettings;
-(void)receiveEvent:(NSString *)params;
- (void)destroy;
@end
