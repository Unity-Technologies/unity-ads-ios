#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <simd/simd.h>

@interface UADSARUtils : NSObject
+ (BOOL)isFrameworkPresent;
+ (BOOL)loadFramework;

// ARSession
+ (id)sessionCreate;
+ (void)arSessionRestart:(id)session
     withConfiguration:(id)configuration
           withOptions:(int)options;
+ (void)sessionPause:(id)session;
+ (void)session:(id)session setDelegate:(id)delegate;
+ (id)sessionGetCurrentFrame:(id)session;
+ (void)sessionAddAnchor:(id)session anchor:(id)anchor;
+ (void)sessionRemoveAnchor:(id)session anchor:(id)anchor;

// ARConfiguration
+ (id)createConfiguration:(const char *)className;
+ (id)createConfigurationFromProperties:(NSDictionary *)properties;
+ (BOOL)arConfigurationIsSupported:(NSString *)configuration;
+ (NSArray *)arConfigurationSupportedVideoFormats:(NSString *)configuration;
+ (void)arConfigurationSetVideoFormat:(id)configuration format:(NSDictionary*)format;

// ARFrame
+ (CVPixelBufferRef)arFrameCapturedImage:(id)frame;
+ (CGAffineTransform)arFrame:(id)frame
displayTransformForOrientation:(UIInterfaceOrientation)orientation
                    viewSize:(CGSize)size;
+ (id)arFrameCamera:(id)frame;
+ (id)arFrameLightEstimate:(id)frame;

// ARCamera
+ (matrix_float4x4)arCamera:(id)camera
projectionMatrixForOrientation:(UIInterfaceOrientation)orientation
               viewportSize:(CGSize)viewportSize
                      zNear:(CGFloat)zNear
                       zFar:(CGFloat)zFar;
+ (matrix_float4x4)arCamera:(id)camera
   viewMatrixForOrientation:(UIInterfaceOrientation)orientation;

// ARAnchor
+ (id)arPlaneAnchorClass;
+ (id)arFaceAnchorClass;
+ (id)anchorInitWithTransform:(matrix_float4x4)transform;
+ (matrix_float4x4)anchorTransform:(id)anchor;
+ (void)arAnchorCenter:(id)anchor center:(float[3])center;
+ (void)arAnchorExtent:(id)anchor extent:(float[3])extent;
+ (NSUUID*)arAnchorIdentifier:(id)anchor;
+ (NSInteger)arPlaneAnchorAlignment:(id)anchor;

// ARLightEstimate
+ (CGFloat)arLightEstimateAmbientIntensity:(id)lightEstimate;
+ (CGFloat)arLightEstimateAmbientColorTemperature:(id)lightEstimate;

// Utility
+ (CGSize)sizeForOrientation:(UIInterfaceOrientation)orientation width:(size_t)width height:(size_t)height;
@end
