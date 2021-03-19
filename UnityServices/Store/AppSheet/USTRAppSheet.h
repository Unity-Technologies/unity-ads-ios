#import <Foundation/Foundation.h>
#import <StoreKit/SKStoreProductViewController.h>

@interface USTRAppSheet : NSObject <SKStoreProductViewControllerDelegate>

- (BOOL)canOpenAppSheet;
- (void)prepareAppSheet:(NSDictionary* _Nonnull)parameters prepareTimeoutInSeconds:(int)timeout completionBlock:(nullable void(^)(BOOL result, NSString * __nullable error))block;
- (void)prepareAppSheetImmediate:(NSDictionary* _Nonnull)parameters prepareTimeoutInSeconds:(int)timeout completionBlock:(nullable void(^)(BOOL result, NSString * __nullable error))block;
- (void)presentAppSheet:(NSDictionary* _Nonnull)parameters animated:(BOOL)animated completionBlock:(nullable void (^)(BOOL result, NSString * __nullable error))block;
-(void)presentAppSheetWithTopViewControllerSupport:(NSDictionary* _Nonnull)parameters animated:(BOOL)animated completionBlock:(nullable void (^)(BOOL result, NSString * __nullable error))block;
- (void)destroyAppSheet;
- (BOOL)destroyAppSheet:(NSDictionary* _Nonnull)parameters;

@property (nonatomic, assign) BOOL canOpenAppSheet;
@property (nonatomic) int prepareTimeoutInSeconds;

@end
