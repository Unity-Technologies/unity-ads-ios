#ifndef UADSARView_h
#define UADSARView_h

#import <UIKit/UIKit.h>
#if !TARGET_IPHONE_SIMULATOR
#import <MetalKit/MetalKit.h>
#endif

@interface UADSARView : UIView

@property (nonatomic) float arNear;
@property (nonatomic) float arFar;
@property (nonatomic, strong) id arSession;
@property (nonatomic, strong) id arConfiguration;
@property (nonatomic) int arRunOptions;
@property (nonatomic) BOOL drawNextCameraFrame;
@property (nonatomic) BOOL showCameraFeed;

@property (nonatomic) CGAffineTransform arVideoTransform;
@property (nonatomic) CGFloat arVideoScaleX;
@property (nonatomic) CGFloat arVideoScaleY;
@property (nonatomic) BOOL arVideoScaled;

#if !TARGET_IPHONE_SIMULATOR
@property (nonatomic, strong) MTKView *mtkView;
#endif

+ (instancetype)getInstance;
- (id)initWithFrame:(CGRect)frame;
- (id)initWithCoder:(NSCoder *)aDecoder;
- (void)addAnchor:(NSString*)identifier withTransform:(NSString*)transform;
- (void)removeAnchor:(NSString*)identifier;

@end

#endif /* UADSARView_h */
