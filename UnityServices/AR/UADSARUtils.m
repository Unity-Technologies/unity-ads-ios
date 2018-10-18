#import <objc/runtime.h>
#import <dlfcn.h>
#import <Foundation/NSObject.h>

#import "UADSARUtils.h"
#import "USRVDevice.h"
#import "USRVWKWebViewUtilities.h"
#import "UADSARView.h"

static void (*sessionAddAnchorFunc)(id, SEL, id) = nil;
static SEL sessionAddAnchorSelector = nil;
static void (*sessionRemoveAnchorFunc)(id, SEL, id) = nil;
static SEL sessionRemoveAnchorSelector = nil;

static CVPixelBufferRef (*frameCapturedImageFunc)(id, SEL) = nil;
static SEL frameCapturedImageSelector = nil;
static id (*frameCameraFunc)(id, SEL) = nil;
static SEL frameCameraSelector = nil;
static id (*frameLightEstimateFunc)(id, SEL) = nil;
static SEL frameLightEstimateSelector = nil;

static CGAffineTransform (*displayTransformForOrientationFunc)(id, SEL, UIInterfaceOrientation, CGSize) = nil;
static SEL displayTransformForOrientationSelector = nil;

static id (*currentFrameFunc)(id, SEL) = nil;
static SEL currentFrameSelector = nil;

static id (*anchorInitWithTransformFunc)(id, SEL, matrix_float4x4) = nil;
static SEL anchorInitWithTransformSelector = nil;
static matrix_float4x4 (*anchorTransformFunc)(id, SEL) = nil;
static SEL anchorTransformSelector = nil;
static vector_float3 (*anchorCenterFunc)(id, SEL) = nil;
static SEL anchorCenterSelector = nil;
static vector_float3 (*anchorExtentFunc)(id, SEL) = nil;
static SEL anchorExtentSelector = nil;
static NSUUID* (*anchorIdentifierFunc)(id, SEL) = nil;
static SEL anchorIdentifierSelector = nil;
static int (*anchorAlignmentFunc)(id, SEL) = nil;
static SEL anchorAlignmentSelector = nil;

static matrix_float4x4 (*cameraProjectionMatrixFunc)(id, SEL, UIInterfaceOrientation, CGSize, CGFloat, CGFloat) = nil;
static SEL cameraProjectionMatrixSelector = nil;
static matrix_float4x4 (*cameraViewMatrixFunc)(id, SEL, UIInterfaceOrientation) = nil;
static SEL cameraViewMatrixSelector = nil;

static CGFloat (*lightEstimateAmbientIntensityFunc)(id, SEL) = nil;
static SEL lightEstimateAmbientIntensitySelector = nil;
static CGFloat (*lightEstimateAmbientColorTemperatureFunc)(id, SEL) = nil;
static SEL lightEstimateAmbientColorTemperatureSelector = nil;

@implementation UADSARUtils {

}

+ (BOOL)isFrameworkPresent {
    id arSessionClass = objc_getClass("ARSession");

    if (arSessionClass) {
        return YES;
    }

    return NO;
}

+ (BOOL)loadFramework {
    NSString *frameworkLocation;

    if (![UADSARUtils isFrameworkPresent]) {
        USRVLogDebug(@"ARKit Framework is not present, trying to load it.");
        if ([USRVDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents:@[frameworkPath, @"ARKit.framework", @"ARKit"]];
            }
        }
        else {
            frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/ARKit.framework/ARKit"];
        }

        dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);

        if (![UADSARUtils isFrameworkPresent]) {
            USRVLogError(@"ARKit still not present!");
            return NO;
        }
        else {
            USRVLogDebug(@"Succesfully loaded ARKit framework");
            return YES;
        }
    }
    else {
        USRVLogDebug(@"ARKit framework already present");
        return YES;
    }
}

+ (id)sessionCreate {
    USRVLogDebug(@"CREATING ARSESSION");
    if (![UADSARUtils loadFramework]) {
        USRVLogWarning(@"Can't load ARKit");
        return nil;
    }

    id class = objc_getClass("ARSession");
    id arsession = nil;

    if (class) {
        arsession = [[class alloc] init];
        
        if (arsession) {
            USRVLogDebug(@"Succesfully created object for ARSession");
        }
    }

    return arsession;
}

+ (void)arSessionRestart:(id)session withConfiguration:(id)configuration
             withOptions:(int)options
{
    if (!session || !configuration) {
        USRVLogError(@"Session or configuration is null");
        return;
    }

    SEL runWithConfigurationSelector = NSSelectorFromString(@"runWithConfiguration:options:");
    if ([session respondsToSelector:runWithConfigurationSelector]) {
        USRVLogDebug(@"session responds to runWithConfiguration");
        IMP runWithConfigurationImp = [session methodForSelector:runWithConfigurationSelector];
        if (runWithConfigurationImp) {
            USRVLogDebug(@"Got runWithConfiguration implementation");
            void (*runWithConfigurationFunc)(id, SEL, id, int) = (void *)runWithConfigurationImp;
            runWithConfigurationFunc(session, runWithConfigurationSelector, configuration, options);
        };
    }
}

+ (void)sessionPause:(id)session {
    if (!session) {
        return;
    }

    SEL pauseSelector = NSSelectorFromString(@"pause");
    if ([session respondsToSelector:pauseSelector]) {
        [session performSelector:pauseSelector];
    }
}

+ (void)sessionAddAnchor:(id)session anchor:(id)anchor {
    if (!session || !anchor) {
        return;
    }

    if (!sessionAddAnchorFunc) {
        sessionAddAnchorSelector = NSSelectorFromString(@"addAnchor:");
        if ([session respondsToSelector:sessionAddAnchorSelector]) {
            IMP sessionAddAnchorImp = [session methodForSelector:sessionAddAnchorSelector];
            if (sessionAddAnchorImp) {
                sessionAddAnchorFunc = (void*) sessionAddAnchorImp;
            }
        }
    }

    return sessionAddAnchorFunc(session, sessionAddAnchorSelector, anchor);
}

+ (void)sessionRemoveAnchor:(id)session anchor:(id)anchor {
    if (!session || !anchor) {
        return;
    }

    if (!sessionRemoveAnchorFunc) {
        sessionRemoveAnchorSelector = NSSelectorFromString(@"removeAnchor:");
        if ([session respondsToSelector:sessionRemoveAnchorSelector]) {
            IMP sessionRemoveAnchorImp = [session methodForSelector:sessionRemoveAnchorSelector];
            if (sessionRemoveAnchorImp) {
                sessionRemoveAnchorFunc = (void*) sessionRemoveAnchorImp;
            }
        }
    }

    return sessionRemoveAnchorFunc(session, sessionRemoveAnchorSelector, anchor);
}

+ (void)session:(id)session setDelegate:(id)delegate {
    if (!session) {
        USRVLogError(@"Session is null");
        return;
    }

    [session setValue:delegate forKey:@"delegate"];
}

+ (id)sessionGetCurrentFrame:(id)session {
    if (!session) {
        USRVLogError(@"Session is null");
        return nil;
    }

    if (!currentFrameFunc) {
        currentFrameSelector = NSSelectorFromString(@"currentFrame");
        if ([session respondsToSelector:currentFrameSelector]) {
            IMP currentFrameImp =  [session methodForSelector:currentFrameSelector];
            if (currentFrameImp) {
                currentFrameFunc = (void *)currentFrameImp;
            }
        }
    }

    return currentFrameFunc(session, currentFrameSelector);
}

+(id)createConfiguration:(const char*)className {
    if (![UADSARUtils loadFramework]) {
        USRVLogWarning(@"Can't load ARKit");
        return nil;
    }
    id class = objc_getClass(className);
    if (!class) {
        USRVLogError(@"Error - can't find class %s", className);
        return nil;
    }
    id configuration = [class new];
    if (!configuration) {
        USRVLogError(@"Error - can't instantiate %s", className);
        return nil;
    }

    return configuration;
}

+ (id)createConfigurationFromProperties:(NSDictionary *)properties {
    id configuration = nil;
    if (!properties) {
        return nil;
    }

    id configurationName = [properties valueForKey:@"configurationName"];
    if (!(configurationName && [configurationName respondsToSelector:@selector(cStringUsingEncoding:)])) {
        return nil;
    }
    configuration = [UADSARUtils createConfiguration:[configurationName cStringUsingEncoding:NSUTF8StringEncoding]];

    if (!configuration) {
        USRVLogError(@"Can't create configuration: %@", properties);
        return nil;
    }

    id lightEstimationEnabled = [properties valueForKey:@"lightEstimationEnabled"];
    if (lightEstimationEnabled && [lightEstimationEnabled isKindOfClass:[NSNumber class]]) {
        [UADSARUtils setConfigurationProperty:configuration name:@"lightEstimationEnabled" value:lightEstimationEnabled];
    }

    id worldAlignment = [properties valueForKey:@"worldAlignment"];
    if (worldAlignment && [worldAlignment isKindOfClass:[NSNumber class]]) {
        [UADSARUtils setConfigurationProperty:configuration name:@"worldAlignment" value:worldAlignment];
    }

    id planeDetection = [properties valueForKey:@"planeDetection"];
    if (planeDetection && [planeDetection isKindOfClass:[NSNumber class]]) {
        [UADSARUtils setConfigurationProperty:configuration name:@"planeDetection" value:planeDetection];
    }

    id autoFocusEnabled = [properties valueForKey:@"autoFocusEnabled"];
    if (autoFocusEnabled && [autoFocusEnabled isKindOfClass:[NSNumber class]]) {
        [UADSARUtils setConfigurationProperty:configuration name:@"autoFocusEnabled" value:autoFocusEnabled];
    }

    NSDictionary *videoFormat = [properties objectForKey:@"videoFormat"];
    if (videoFormat) {
        [UADSARUtils arConfigurationSetVideoFormat:configuration format:videoFormat];
    }

    return configuration;
}

+ (void)setConfigurationProperty:(id)configuration name:(NSString *)name value:(id)value {
    Class clazz = [configuration class];
    objc_property_t property = class_getProperty(clazz, [name cStringUsingEncoding:NSUTF8StringEncoding]);
    if (property) {
        [configuration setValue:value forKey:name];
    }
}

+(BOOL)arConfigurationIsSupported:(NSString *)configuration {
    if (!configuration) {
        USRVLogError(@"Configuration is null");
        return NO;
    }

    if (![UADSARUtils loadFramework]) {
        return NO;
    }

    id configClass = objc_getClass([configuration cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!configClass || ![configClass respondsToSelector:NSSelectorFromString(@"isSupported")]) {
        return NO;
    }

    return [(NSNumber*)[configClass valueForKey:@"isSupported"] boolValue];
}

+ (NSArray *)arConfigurationSupportedVideoFormats:(NSString *)configuration {
    if (!configuration) {
        USRVLogError(@"Configuration is null");
        return nil;
    }

    NSArray *videoFormats = [UADSARUtils getArConfigurationVideoFormats:configuration];
    if (!videoFormats) {
        return nil;
    }

    NSMutableArray *result = [[NSMutableArray alloc] init];

    for (id format in videoFormats) {
        CGSize size = [[format valueForKey:@"imageResolution"] CGSizeValue];
        NSInteger fps = [[format valueForKey:@"framesPerSecond"] integerValue];
        NSDictionary *f = @{
                            @"imageResolution": @{
                                    @"width": [NSNumber numberWithFloat:size.width],
                                    @"heigth": [NSNumber numberWithFloat:size.height],
                                    },
                            @"framesPerSecond": [NSNumber numberWithInteger:fps],
                            };
        [result addObject:f];
    }

    return result;
}

+ (NSArray *)getArConfigurationVideoFormats:(NSString *)configName {
    id configClass = objc_getClass([configName cStringUsingEncoding:NSUTF8StringEncoding]);
    if (!configClass || ![configClass respondsToSelector:NSSelectorFromString(@"supportedVideoFormats")]) {
        return nil;
    }

    NSArray *videoFormats = (NSArray *)[configClass valueForKey:@"supportedVideoFormats"];
    return videoFormats;
}

+ (void)arConfigurationSetVideoFormat:(id)configuration format:(NSDictionary *)format {
    if (!configuration) {
        USRVLogError(@"Configuration is null");
        return;
    }

    NSArray *supportedFormats = [UADSARUtils getArConfigurationVideoFormats:NSStringFromClass([configuration class])];
    if (!supportedFormats) {
        USRVLogWarning(@"Configuration doesn't support format selection");
        return;
    }

    id videoFormat = nil;
    for (id f in supportedFormats) {
        CGSize size = [[f valueForKey:@"imageResolution"] CGSizeValue];
        NSInteger fps = [[f valueForKey:@"framesPerSecond"] integerValue];
        NSDictionary *imageResolution = [format valueForKey:@"imageResolution"];
        CGSize size2 = CGSizeMake([[imageResolution valueForKey:@"width"] floatValue],
                                  [[imageResolution valueForKey:@"height"] floatValue]);
        NSInteger fps2 = [[format valueForKey:@"framesPerSecond"] integerValue];

        if (CGSizeEqualToSize(size, size2) && fps == fps2) {
            videoFormat = f;
            break;
        }
    }

    if (videoFormat) {
        [configuration setValue:videoFormat forKey:@"videoFormat"];
    } else {
        USRVLogWarning(@"Failed to set video format for configuration");
    }
}

+ (CVPixelBufferRef)arFrameCapturedImage:(id)frame {
    if (!frame) {
        USRVLogError(@"Frame is null");
        return nil;
    }

    if (!frameCapturedImageFunc) {
        frameCapturedImageSelector = NSSelectorFromString(@"capturedImage");
        if ([frame respondsToSelector:frameCapturedImageSelector]) {
            IMP capturedImageImp = [frame methodForSelector:frameCapturedImageSelector];
            if (capturedImageImp) {
                frameCapturedImageFunc = (void *)capturedImageImp;
            }
        }
    }

    return frameCapturedImageFunc(frame, frameCapturedImageSelector);
}

+ (CGAffineTransform)arFrame:(id)frame
displayTransformForOrientation:(UIInterfaceOrientation)orientation
                   viewSize:(CGSize)size {
    if (!frame) {
        USRVLogError(@"Frame is null");
        return CGAffineTransformIdentity;
    }

    if (!displayTransformForOrientationFunc) {
        displayTransformForOrientationSelector = NSSelectorFromString(@"displayTransformForOrientation:viewportSize:");
        if ([frame respondsToSelector:displayTransformForOrientationSelector]) {
            IMP displayTransformForOrientationImp = [frame methodForSelector:displayTransformForOrientationSelector];
            if (displayTransformForOrientationImp) {
                displayTransformForOrientationFunc = (void*)displayTransformForOrientationImp;
            }
        }
    }

    return displayTransformForOrientationFunc(frame, displayTransformForOrientationSelector, orientation, size);
}

+ (id)arFrameCamera:(id)frame {
    if (!frame) {
        USRVLogError(@"Frame is null");
        return nil;
    }

    if (!frameCameraFunc) {
        frameCameraSelector = NSSelectorFromString(@"camera");
        if ([frame respondsToSelector:frameCameraSelector]) {
            IMP frameCameraImp = [frame methodForSelector:frameCameraSelector];
            if (frameCameraImp) {
                frameCameraFunc = (void*)frameCameraImp;
            }
        }
    }

    return frameCameraFunc(frame, frameCameraSelector);
}

+ (id)arFrameLightEstimate:(id)frame {
    if (!frame) {
        USRVLogError(@"Frame is null");
        return nil;
    }

    if (!frameLightEstimateFunc) {
        frameLightEstimateSelector = NSSelectorFromString(@"lightEstimate");
        if ([frame respondsToSelector:frameLightEstimateSelector]) {
            IMP frameLightEstimateImp = [frame methodForSelector:frameLightEstimateSelector];
            if (frameLightEstimateImp) {
                frameLightEstimateFunc = (void*)frameLightEstimateImp;
            }
        }
    }

    return frameLightEstimateFunc(frame, frameLightEstimateSelector);
}

+ (id)arPlaneAnchorClass {
    return objc_getClass("ARPlaneAnchor");
}

+ (id)arFaceAnchorClass {
    return objc_getClass("ARFaceAnchor");
}

+ (id)anchorInitWithTransform:(matrix_float4x4)transform {
    if (![UADSARUtils loadFramework]) {
        USRVLogError(@"ARKit is not present");
        return nil;
    }

    id anchorClass = objc_getClass("ARAnchor");
    id anchor = [anchorClass alloc];

    if (!anchorInitWithTransformFunc) {
        anchorInitWithTransformSelector = NSSelectorFromString(@"initWithTransform:");
        if ([anchor respondsToSelector:anchorInitWithTransformSelector]) {
            IMP anchorInitWithTransformImp = [anchor methodForSelector:anchorInitWithTransformSelector];
            if (anchorInitWithTransformImp) {
                anchorInitWithTransformFunc = (void*)anchorInitWithTransformImp;
            }
        }
    }

    return anchorInitWithTransformFunc(anchor, anchorInitWithTransformSelector, transform);
}

+ (matrix_float4x4)anchorTransform:(id)anchor {
    if (!anchor) {
        USRVLogError(@"Anchor is null");
        return matrix_identity_float4x4;
    }

    if (!anchorTransformFunc) {
        anchorTransformSelector = NSSelectorFromString(@"transform");
        if ([anchor respondsToSelector:anchorTransformSelector]) {
            IMP anchorTransformImp = [anchor methodForSelector:anchorTransformSelector];
            if (anchorTransformImp) {
                anchorTransformFunc = (void*)anchorTransformImp;
            }
        }
    }

    return anchorTransformFunc(anchor, anchorTransformSelector);
}

+ (void)arAnchorCenter:(id)anchor center:(float[3])center {
    if (!anchor) {
        USRVLogError(@"Anchor is null");
        return;
    }

    if (!anchorCenterFunc) {
        anchorCenterSelector = NSSelectorFromString(@"center");
        if ([anchor respondsToSelector:anchorCenterSelector]) {
            IMP anchorCenterImp = [anchor methodForSelector:anchorCenterSelector];
            if (anchorCenterImp) {
                anchorCenterFunc = (void*)anchorCenterImp;
            }
        }
    }

    vector_float3 result = anchorCenterFunc(anchor, anchorCenterSelector);
    center[0] = result.x;
    center[1] = result.y;
    center[2] = result.z;
}

+ (void)arAnchorExtent:(id)anchor extent:(float[3])extent {
    if (!anchor) {
        USRVLogError(@"Anchor is null");
        return;
    }

    if (!anchorExtentFunc) {
        anchorExtentSelector = NSSelectorFromString(@"extent");
        if ([anchor respondsToSelector:anchorExtentSelector]) {
            IMP anchorExtentImp = [anchor methodForSelector:anchorExtentSelector];
            if (anchorExtentImp) {
                anchorExtentFunc = (void*) anchorExtentImp;
            }
        }
    }

    vector_float3 result = anchorExtentFunc(anchor, anchorExtentSelector);
    extent[0] = result.x;
    extent[1] = result.y;
    extent[2] = result.z;
}

+ (NSUUID*)arAnchorIdentifier:(id)anchor {
    if (!anchor) {
        USRVLogError(@"Anchor is null");
        return nil;
    }

    if (!anchorIdentifierFunc) {
        anchorIdentifierSelector = NSSelectorFromString(@"identifier");
        if ([anchor respondsToSelector:anchorIdentifierSelector]) {
            IMP anchorIdentifierImp = [anchor methodForSelector:anchorIdentifierSelector];
            if (anchorIdentifierImp) {
                anchorIdentifierFunc = (void*) anchorIdentifierImp;
            }
        }
    }

    return anchorIdentifierFunc(anchor, anchorIdentifierSelector);
}

+ (NSInteger)arPlaneAnchorAlignment:(id)anchor {
    if (!anchor) {
        USRVLogError(@"Anchor is null");
        return 0;
    }

    if (!anchorAlignmentFunc) {
        anchorAlignmentSelector = NSSelectorFromString(@"alignment");
        if ([anchor respondsToSelector:anchorAlignmentSelector]) {
            IMP anchorAlignmentImp = [anchor methodForSelector:anchorAlignmentSelector];
            if (anchorAlignmentImp) {
                anchorAlignmentFunc = (void*) anchorAlignmentImp;
            }
        }
    }

    return anchorAlignmentFunc(anchor, anchorAlignmentSelector);
}

+ (matrix_float4x4)arCamera:(id)camera
projectionMatrixForOrientation:(UIInterfaceOrientation)orientation
               viewportSize:(CGSize)viewportSize
                      zNear:(CGFloat)zNear
                       zFar:(CGFloat)zFar {
    if (!camera) {
        USRVLogError(@"Camera is null");
        return matrix_identity_float4x4;
    }

    if (!cameraProjectionMatrixFunc) {
        cameraProjectionMatrixSelector = NSSelectorFromString(@"projectionMatrixForOrientation:viewportSize:zNear:zFar:");
        if ([camera respondsToSelector:cameraProjectionMatrixSelector]) {
            IMP cameraProjectionMatrixImp = [camera methodForSelector:cameraProjectionMatrixSelector];
            if (cameraProjectionMatrixImp) {
                cameraProjectionMatrixFunc = (void*) cameraProjectionMatrixImp;
            }
        }
    }

    return cameraProjectionMatrixFunc(camera, cameraProjectionMatrixSelector, orientation, viewportSize, zNear, zFar);
}

+ (matrix_float4x4)arCamera:(id)camera
   viewMatrixForOrientation:(UIInterfaceOrientation)orientation {
    if (!camera) {
        USRVLogError(@"Camera is null");
        return matrix_identity_float4x4;
    }

    if (!cameraViewMatrixFunc) {
        cameraViewMatrixSelector = NSSelectorFromString(@"viewMatrixForOrientation:");
        if ([camera respondsToSelector:cameraViewMatrixSelector]) {
            IMP cameraViewMatrixImp = [camera methodForSelector:cameraViewMatrixSelector];
            if (cameraViewMatrixImp) {
                cameraViewMatrixFunc = (void*) cameraViewMatrixImp;
            }
        }
    }

    return cameraViewMatrixFunc(camera, cameraViewMatrixSelector, orientation);
}

+ (CGFloat)arLightEstimateAmbientIntensity:(id)lightEstimate {
    if (!lightEstimate) {
        USRVLogError(@"Light estimate is null");
        return 0.0f;
    }

    if (!lightEstimateAmbientIntensityFunc) {
        lightEstimateAmbientIntensitySelector = NSSelectorFromString(@"ambientIntensity");
        if ([lightEstimate respondsToSelector:lightEstimateAmbientIntensitySelector]) {
            IMP imp = [lightEstimate methodForSelector:lightEstimateAmbientIntensitySelector];
            if (imp) {
                lightEstimateAmbientIntensityFunc = (void*) imp;
            }
        }
    }

    return lightEstimateAmbientIntensityFunc(lightEstimate, lightEstimateAmbientIntensitySelector);
}

+ (CGFloat)arLightEstimateAmbientColorTemperature:(id)lightEstimate {
    if (!lightEstimate) {
        USRVLogError(@"Light estimate is null");
        return 0.0f;
    }

    if (!lightEstimateAmbientColorTemperatureFunc) {
        lightEstimateAmbientColorTemperatureSelector = NSSelectorFromString(@"ambientColorTemperature");
        if ([lightEstimate respondsToSelector:lightEstimateAmbientColorTemperatureSelector]) {
            IMP imp = [lightEstimate methodForSelector:lightEstimateAmbientColorTemperatureSelector];
            if (imp) {
                lightEstimateAmbientColorTemperatureFunc = (void*) imp;
            }
        }
    }

    return lightEstimateAmbientColorTemperatureFunc(lightEstimate, lightEstimateAmbientColorTemperatureSelector);
}

+ (CGSize)sizeForOrientation:(UIInterfaceOrientation)orientation width:(size_t)width height:(size_t)height {
    CGSize size;

    if(UIInterfaceOrientationIsLandscape(orientation)) {
        size.width = MAX(width, height);
        size.height = MIN(width, height);
    }
    else {
        size.width = MIN(width, height);
        size.height = MAX(width, height);
    }

    return size;
}
@end
