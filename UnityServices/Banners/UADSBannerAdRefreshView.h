#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UADSBannerAdRefreshViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSBannerAdRefreshView : UIView

@property(nonatomic, readonly) CGSize size;
@property(nonatomic, readwrite, nullable, weak) NSObject <UADSBannerAdRefreshViewDelegate> *delegate;
@property(nonatomic, readonly) NSString *placementId;
@property(nonatomic, readonly) NSString *viewId;

-(instancetype)initWithPlacementId:(NSString *)placementId size:(CGSize)size;

-(void)load;

@end

NS_ASSUME_NONNULL_END
