#import <Foundation/Foundation.h>

#import "UADSARView.h"
#import "UADSARUtils.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"
#import "UADSAREvent.h"

#define FBOX(x) [NSNumber numberWithFloat:x]
#define FRAME_UPDATE_TIMEOUT 0.5

static UADSARView *current = nil;

#if !TARGET_IPHONE_SIMULATOR
@interface UADSARView () <MTKViewDelegate>
@end
#endif

@implementation UADSARView {
#if !TARGET_IPHONE_SIMULATOR
    id<MTLCommandQueue> commandQueue;
#endif
    CIContext *ciContext;
    CGColorSpaceRef colorSpace;
    UIDeviceOrientation deviceOrientation;
    UIInterfaceOrientation interfaceOrientation;
    BOOL sendARFrame;
    BOOL updateWindowSize;
    CFTimeInterval timeOfLastDrawnCameraFrame;
    CIImage *testImage;
    NSMutableDictionary *jsAnchorIdsToObjCAnchorIds;
    NSMutableDictionary *objCAnchorIdsToJSAnchorIds;
    NSMutableDictionary *anchors;
}

+ (instancetype)getInstance {
    return current;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    USRVLogDebug(@"self.frame: (%f, %f, %f, %f)", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
#if TARGET_IPHONE_SIMULATOR
    return;
#else
    current = self;
    timeOfLastDrawnCameraFrame = 0;
    [self initAR];
    self.mtkView = [[MTKView alloc] initWithFrame:self.frame device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    self.mtkView.autoResizeDrawable = YES;
    self.mtkView.framebufferOnly = NO;
    [self addSubview:self.mtkView];
    ciContext = [CIContext contextWithMTLDevice:self.mtkView.device];
    commandQueue = [self.mtkView.device newCommandQueue];
    colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat testcolor[] = {1, 0.5, 0, 1};
    CGColorRef cgColor = CGColorCreate(CGColorSpaceCreateDeviceRGB(), testcolor);
    testImage = [CIImage imageWithColor:[CIColor colorWithCGColor:cgColor]];
    self.arNear = 0.01f;
    self.arFar = 10000.0f;
    self.showCameraFeed = NO;
    self.arVideoScaled = NO;
    self.arVideoTransform = CGAffineTransformIdentity;
    sendARFrame = NO;
    updateWindowSize = NO;
    interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    jsAnchorIdsToObjCAnchorIds = [[NSMutableDictionary alloc] init];
    objCAnchorIdsToJSAnchorIds = [[NSMutableDictionary alloc] init];
    anchors = [[NSMutableDictionary alloc] init];
    [self adjustVideoScaling];
#endif
}

- (void)initAR {
    self.arRunOptions = 0;
    self.arSession = [UADSARUtils sessionCreate];
    self.arConfiguration = [UADSARUtils createConfiguration:"ARWorldTrackingConfiguration"];

    if (self.arSession) {
        [UADSARUtils session:self.arSession setDelegate:self];
    }
}

- (void)addAnchor:(NSString *)identifier withTransform:(NSString *)transform {
    matrix_float4x4 modelMatrix;
    float *pModelMatrix = (float*)(&modelMatrix);
    NSArray *params = [transform componentsSeparatedByString:@","];

    for (int i = 0; i < 16; i++) {
        pModelMatrix[i] = [params[i] floatValue];
    }

    id anchor = [UADSARUtils anchorInitWithTransform:modelMatrix];
    [UADSARUtils sessionAddAnchor:self.arSession anchor:anchor];
    // Create an entry to convert from the js id to the objective c id (and
    // viceversa)
    NSString *anchorId = [UADSARUtils arAnchorIdentifier:anchor].UUIDString;
    [jsAnchorIdsToObjCAnchorIds setValue:anchorId forKey:identifier];
    [objCAnchorIdsToJSAnchorIds setValue:identifier forKey:anchorId];
    [anchors setValue:anchor forKey:identifier];
}

// Retrive the ARAnchor from the jsAnchorId and remove it from the
// session. Of course, also remove all the id mapping and the anchor
// from the anchors container.
- (void)removeAnchor:(NSString *)identifier {
    id anchor = anchors[identifier];
    [UADSARUtils sessionRemoveAnchor:self.arSession anchor:anchor];
    NSString *objCAnchorId = [UADSARUtils arAnchorIdentifier:anchor].UUIDString;
    [jsAnchorIdsToObjCAnchorIds removeObjectForKey:identifier];
    [objCAnchorIdsToJSAnchorIds removeObjectForKey:objCAnchorId];
    [anchors removeObjectForKey:identifier];
}

- (void)layoutSubviews {
    USRVLogDebug(@"LAYOUTSUBVIEWS %@", NSStringFromCGRect(self.frame));
    [super layoutSubviews];
    updateWindowSize = YES;
#if !TARGET_IPHONE_SIMULATOR
    [self.mtkView setFrame:self.frame];
#endif
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    if (self.arSession) {
        [UADSARUtils sessionPause:self.arSession];
    }
    if (current == self) {
        current = nil;
    }
}

#if !TARGET_IPHONE_SIMULATOR
- (void)drawInMTKView:(nonnull MTKView *)view {
    interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];

    id arFrame = nil;
    if (!(arFrame = [UADSARUtils sessionGetCurrentFrame:self.arSession]) || !view.currentDrawable || !view.currentRenderPassDescriptor) {
        return;
    }

    CFTimeInterval currentTime = CACurrentMediaTime();
    if (timeOfLastDrawnCameraFrame == 0) {
        timeOfLastDrawnCameraFrame = currentTime;
    }
    CFTimeInterval timeSinceLastDrawnCameraFrame = currentTime - timeOfLastDrawnCameraFrame;
    if (timeSinceLastDrawnCameraFrame < FRAME_UPDATE_TIMEOUT && !self.drawNextCameraFrame) {
        return;
    }
    sendARFrame = YES;
    timeOfLastDrawnCameraFrame = currentTime;
    self.drawNextCameraFrame = NO;

    if (!self.showCameraFeed) {
        return;
    }

    CVPixelBufferRef pbRef = [UADSARUtils arFrameCapturedImage:arFrame];

    size_t videoWidth, videoHeight;
    videoWidth = CVPixelBufferGetWidth(pbRef);
    videoHeight = CVPixelBufferGetHeight(pbRef);

    // Get transform for rotating the camera image to the interface orientation
    // (use video size instead of display size to avoid conversion from normalized
    // image coordinates)
    self.arVideoTransform = [UADSARUtils arFrame:arFrame
                  displayTransformForOrientation:interfaceOrientation
                                        viewSize:[UADSARUtils sizeForOrientation:interfaceOrientation width:videoWidth height:videoHeight]];

    if (!self.arVideoScaled) {
        [self adjustVideoScaling];
    }
    self.arVideoScaled = NO;

    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pbRef];

    CGAffineTransform invertedTransform = CGAffineTransformInvert(self.arVideoTransform);
    CGAffineTransform scalingTransform = CGAffineTransformMakeScale(self.arVideoScaleX, self.arVideoScaleY);

    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformConcat(invertedTransform, scalingTransform)];

    // Center the rotated and scaled image
    CGFloat xOffset = -ciImage.extent.origin.x - ciImage.extent.size.width / 2.0f + self.mtkView.drawableSize.width / 2.0f;
    CGFloat yOffset = -ciImage.extent.origin.y - ciImage.extent.size.height / 2.0f + self.mtkView.drawableSize.height / 2.0f;

    ciImage = [ciImage imageByApplyingTransform:CGAffineTransformMakeTranslation(xOffset, yOffset)];

    CGRect bounds = CGRectMake(0.0f, 0.0f, self.mtkView.drawableSize.width, self.mtkView.drawableSize.height);

    id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    [ciContext render:ciImage
               toMTLTexture:self.mtkView.currentDrawable.texture
               commandBuffer:commandBuffer bounds:bounds colorSpace:colorSpace];
    [commandBuffer presentDrawable:self.mtkView.currentDrawable];
    [commandBuffer commit];
}

- (void)adjustVideoScaling {
    id arFrame = [UADSARUtils sessionGetCurrentFrame:self.arSession];
    if (!arFrame) {
        return;
    }

    CVPixelBufferRef pbRef = [UADSARUtils arFrameCapturedImage:arFrame];
    if (!pbRef) {
        return;
    }

    size_t videoWidth, videoHeight;
    videoWidth = CVPixelBufferGetWidth(pbRef);
    videoHeight = CVPixelBufferGetHeight(pbRef);
    CGRect videoExtent = CGRectApplyAffineTransform(CGRectMake(0, 0, videoWidth, videoHeight), CGAffineTransformInvert(self.arVideoTransform));

    // Calculate scaling for aspect fill
    CGFloat videoAspectRatio = videoExtent.size.width / videoExtent.size.height;
    CGFloat drawableAspectRatio = self.mtkView.drawableSize.width / self.mtkView.drawableSize.height;

    CGFloat dstWidth = self.mtkView.drawableSize.width;
    CGFloat dstHeight = self.mtkView.drawableSize.height;

    if(drawableAspectRatio > videoAspectRatio) {
        dstHeight *= drawableAspectRatio * (1.0f / videoAspectRatio);
    }
    else {
        dstWidth *= (1.0f / drawableAspectRatio) * videoAspectRatio;
    }

    self.arVideoScaleX = (dstWidth / videoExtent.size.width);
    self.arVideoScaleY = (dstHeight / videoExtent.size.height);
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    USRVLogDebug(@"DRAWABLESIZEWILLCHANGE SIZE: %@", NSStringFromCGSize(size));
}

#pragma mark - ARSessionDelegate
- (void)session:(id)session didFailWithError:(NSError *)error {
    USRVLogDebug(@"didFailWithError %@", error);
    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARError)
                                     category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                       param1:[NSNumber numberWithInteger:error.code], nil];
}

- (void)sessionWasInterrupted:(id)session {
    USRVLogDebug(@"sessionWasInterrupted %@", session);
    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARSessionInterrupted)
                                     category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                       param1:nil];
}

- (void)sessionInterruptionEnded:(id)session {
    USRVLogDebug(@"sessionInterruptionEnded %@", session);
    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARSessionInterruptionEnded)
                                     category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                       param1:nil];
}

- (void)session:(id)session didAddAnchors:(nonnull NSArray<id> *)anchors {
    NSString *planesString = [self getPlanesString:anchors];
    if (planesString) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARPlanesAdded)
                                         category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                           param1:planesString, nil];
    }
}

- (void)session:(id)session didUpdateAnchors:(nonnull NSArray<id> *)anchors {
    NSString *planesString = [self getPlanesString:anchors];
    if (planesString) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARPlanesUpdated)
                                         category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                           param1:planesString, nil];
    }
}

- (void)session:(id)session didRemoveAnchors:(nonnull NSArray<id> *)anchors {
    NSString *planesString = [self getPlanesString:anchors];
    if (planesString) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARPlanesRemoved)
                                         category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                           param1:planesString, nil];
    }
    NSString *anchorsString = [self getAnchorsString:anchors];
    if (anchorsString) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARAnchorsUpdated)
                                         category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                           param1:anchorsString, nil];
    }
}

- (void)session:(id)session didUpdateFrame:(id)frame {
    if (!sendARFrame) {
        return;
    }
    
    // Send the per frame data needed in the JS side
    id camera = [UADSARUtils arFrameCamera:frame];
    UIView *wkWebView = [[USRVWebViewApp getCurrentApp] webView];
    matrix_float4x4 viewMatrix = [UADSARUtils arCamera:camera viewMatrixForOrientation:interfaceOrientation];
    matrix_float4x4 modelMatrix = matrix_invert(viewMatrix);
    matrix_float4x4 projectionMatrix = [UADSARUtils arCamera:camera
                              projectionMatrixForOrientation:interfaceOrientation
                                                viewportSize:CGSizeMake(wkWebView.frame.size.width,
                                                                        wkWebView.frame.size.height)
                                                       zNear:[self arNear] zFar:[self arFar]];
    
    const float *pModelMatrix = (const float *)(&modelMatrix);
    const float *pViewMatrix = (const float *)(&viewMatrix);
    const float *pProjectionMatrix = (const float *)(&projectionMatrix);

    float orientationQuat[4];
    matrix4x4ToQuaternion(pModelMatrix, orientationQuat);
    const float *pOrientationQuat = orientationQuat;
    float position[3];
    position[0] = pModelMatrix[12];
    position[1] = pModelMatrix[13];
    position[2] = pModelMatrix[14];

    id lightEstimate = [UADSARUtils arFrameLightEstimate:frame];
    CGFloat ambientIntensity = [UADSARUtils arLightEstimateAmbientIntensity:lightEstimate];
    CGFloat ambientColorTemperature = [UADSARUtils arLightEstimateAmbientColorTemperature:lightEstimate];
    
    NSDictionary* jsonDictionary = @{
                                     @"position":
                                         @[FBOX(position[0]), FBOX(position[1]), FBOX(position[2])],
                                     @"orientation":
                                         @[FBOX(pOrientationQuat[0]), FBOX(pOrientationQuat[1]),
                                           FBOX(pOrientationQuat[2]), FBOX(pOrientationQuat[3])],
                                     @"viewMatrix":
                                         @[FBOX(pViewMatrix[0]), FBOX(pViewMatrix[1]),
                                           FBOX(pViewMatrix[2]), FBOX(pViewMatrix[3]),
                                           FBOX(pViewMatrix[4]), FBOX(pViewMatrix[5]),
                                           FBOX(pViewMatrix[6]), FBOX(pViewMatrix[7]),
                                           FBOX(pViewMatrix[8]), FBOX(pViewMatrix[9]),
                                           FBOX(pViewMatrix[10]), FBOX(pViewMatrix[11]),
                                           FBOX(pViewMatrix[12]), FBOX(pViewMatrix[13]),
                                           FBOX(pViewMatrix[14]), FBOX(pViewMatrix[15])],
                                     @"projectionMatrix":
                                         @[FBOX(pProjectionMatrix[0]),
                                           FBOX(pProjectionMatrix[1]),
                                           FBOX(pProjectionMatrix[2]),
                                           FBOX(pProjectionMatrix[3]),
                                           FBOX(pProjectionMatrix[4]),
                                           FBOX(pProjectionMatrix[5]),
                                           FBOX(pProjectionMatrix[6]),
                                           FBOX(pProjectionMatrix[7]),
                                           FBOX(pProjectionMatrix[8]),
                                           FBOX(pProjectionMatrix[9]),
                                           FBOX(pProjectionMatrix[10]),
                                           FBOX(pProjectionMatrix[11]),
                                           FBOX(pProjectionMatrix[12]),
                                           FBOX(pProjectionMatrix[13]),
                                           FBOX(pProjectionMatrix[14]),
                                           FBOX(pProjectionMatrix[15])],
                                     @"lightEstimate":
                                         lightEstimate == nil ? [NSNull null] :
                                         @{@"ambientIntensity":
                                               FBOX(ambientIntensity),
                                           @"ambientColorTemperature":
                                               FBOX(ambientColorTemperature)}
                                     };

    NSError* error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    
    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARFrameUpdated)
                                     category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                       param1:jsonString, nil];

    // This needs to be called after because the window size will affect the
    // projection matrix calculation upon resize
    if (updateWindowSize) {
        int width = self.frame.size.width;
        int height = self.frame.size.height;
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAREvent(kUnityAdsARWindowResized)
                                         category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAR)
                                           param1:FBOX(width), FBOX(height), nil];
        updateWindowSize = NO;
    }

    sendARFrame = NO;
}

- (NSString *)getPlanesString:(nonnull NSArray<id> *)anchors {
    // Return nil if no planes are among the anchors
    NSString *result = nil;
    for (int i = 0; i < anchors.count; i++) {
        if (![anchors[i] isKindOfClass:[UADSARUtils arPlaneAnchorClass]]) {
            // We only want anchors of type plane.
            continue;
        }
        // Now that we know that there is at least one plane among the anchors,
        // create the returning string.
        if (result == nil) {
            result = @"[";
        }
        __weak id plane = anchors[i];
        matrix_float4x4 planeTransform = [UADSARUtils anchorTransform:plane];
        const float *planeMatrix = (const float *)(&planeTransform);
        float anchorCenter[3];
        float anchorExtent[3];
        [UADSARUtils arAnchorCenter:plane center:anchorCenter];
        [UADSARUtils arAnchorExtent:plane extent:anchorExtent];
        NSInteger alignment = [UADSARUtils arPlaneAnchorAlignment:plane];
        NSString *planeStr = [NSString
                              stringWithFormat:
                              @"{\"modelMatrix\":[%f,%f,%f,%f,%f,%f,%f,%f,"
                              @"%f,%f,%f,%f,%f,%f,%f,%f],"
                              @"\"identifier\":%i,"
                              @"\"extent\":[%f,%f],"
                              @"\"vertices\":[%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f],"
                              @"\"alignment\": %ld}",
                              planeMatrix[0], planeMatrix[1], planeMatrix[2], planeMatrix[3],
                              planeMatrix[4], planeMatrix[5], planeMatrix[6], planeMatrix[7],
                              planeMatrix[8], planeMatrix[9], planeMatrix[10], planeMatrix[11],
                              planeMatrix[12] + anchorCenter[0],
                              planeMatrix[13] + anchorCenter[1],
                              planeMatrix[14] + anchorCenter[2],
                              planeMatrix[15],
                              (int)[UADSARUtils arAnchorIdentifier:plane],
                              anchorExtent[0], anchorExtent[2],
                              anchorExtent[0] / 2,
                              0.0,
                              anchorExtent[2] / 2,
                              -anchorExtent[0] / 2,
                              0.0,
                              anchorExtent[2] / 2,
                              -anchorExtent[0] / 2,
                              0.0,
                              -anchorExtent[2] / 2,
                              anchorExtent[0] / 2,
                              0.0,
                              -anchorExtent[2] / 2,
                              (long)alignment];
        planeStr = [planeStr stringByAppendingString:@","];
        result = [result stringByAppendingString:planeStr];
    }
    // Remove the last coma if there is any string
    if (result != nil) {
        result = [result substringToIndex:result.length - 1];
        result = [result stringByAppendingString:@"]"];
    }
    return result;
}

- (NSString *)getAnchorsString:(nonnull NSArray<id> *)anchors {
    NSString *result = nil;
    for (int i = 0; i < anchors.count; i++) {
        if ([anchors[i] isKindOfClass:[UADSARUtils arPlaneAnchorClass]] ||
            [anchors[i] isKindOfClass:[UADSARUtils arFaceAnchorClass]]) {
            // We do not want Plane or Face anchors.
            continue;
        }
        if (result == nil) {
            result = @"[";
        }
        id anchor = anchors[i];
        matrix_float4x4 anchorTransform = [UADSARUtils anchorTransform:anchor];
        const float *anchorMatrix = (const float *)(&anchorTransform);
        NSString *jsAnchorId = objCAnchorIdsToJSAnchorIds[[UADSARUtils arAnchorIdentifier:anchor].UUIDString];
        NSString *anchorStr = [NSString
                               stringWithFormat:
                               @"{\"modelMatrix\":[%f,%f,%f,%f,%f,%f,%f,%f,"
                               @"%f,%f,%f,%f,%f,%f,%f,%f],"
                               @"\"identifier\":%@}",
                               anchorMatrix[0], anchorMatrix[1], anchorMatrix[2], anchorMatrix[3],
                               anchorMatrix[4], anchorMatrix[5], anchorMatrix[6], anchorMatrix[7],
                               anchorMatrix[8], anchorMatrix[9], anchorMatrix[10],
                               anchorMatrix[11], anchorMatrix[12], anchorMatrix[13],
                               anchorMatrix[14], anchorMatrix[15], jsAnchorId];
        anchorStr = [anchorStr stringByAppendingString:@","];
        result = [result stringByAppendingString:anchorStr];
    }
    // Remove the last coma if there is any string
    if (result != nil) {
        result = [result substringToIndex:result.length - 1];
        result = [result stringByAppendingString:@"]"];
    }
    return result;
}

// Algorithm taken from:
// https://d3cw3dd2w32x2b.cloudfront.net/wp-content/uploads/2015/01/matrix-to-quat.pdf
static void matrix4x4ToQuaternion(const float *m, float q[4]) {
    float t;
    if (m[10] < 0) {
        if (m[0] > m[5]) {
            t = 1 + m[0] - m[5] - m[10];
            q[0] = t;
            q[1] = m[1] + m[4];
            q[2] = m[8] + m[2];
            q[3] = m[6] - m[9];
        } else {
            t = 1 - m[0] + m[5] - m[10];
            q[0] = m[1] + m[4];
            q[1] = t;
            q[2] = m[6] + m[9];
            q[3] = m[8] - m[2];
        }
    } else {
        if (m[0] < -m[5]) {
            t = 1 - m[0] - m[5] + m[10];
            q[0] = m[8] + m[2];
            q[1] = m[6] + m[9];
            q[2] = t;
            q[3] = m[1] - m[4];
        } else {
            t = 1 + m[0] + m[5] + m[10];
            q[0] = m[6] - m[9];
            q[1] = m[8] - m[2];
            q[2] = m[1] - m[4];
            q[3] = t;
        }
    }

    q[0] *= 0.5f / sqrtf(t);
    q[1] *= 0.5f / sqrtf(t);
    q[2] *= 0.5f / sqrtf(t);
    q[3] *= 0.5f / sqrtf(t);
}

#endif

@end
