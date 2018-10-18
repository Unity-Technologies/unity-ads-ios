#import "UARApiAR.h"
#import "UADSARUtils.h"
#import "USRVWebViewCallback.h"
#import "UADSARView.h"

#define FBOX(x) [NSNumber numberWithFloat:x]
#define IBOX(x) [NSNumber numberWithInteger:x]

@implementation UARApiAR

+ (void)WebViewExposed_isARSupported:(NSString *)configName callback:(USRVWebViewCallback *)callback {
    BOOL isSupported = [UADSARUtils arConfigurationIsSupported:configName];
    [callback invoke:[NSNumber numberWithBool:isSupported], nil];
}

+ (void)WebViewExposed_getSupportedVideoFormats:(NSString *)configName callback:(USRVWebViewCallback *)callback {
    NSArray *formats = [UADSARUtils arConfigurationSupportedVideoFormats:configName];
    [callback invoke:(formats != nil) ? formats : [NSNull null], nil];
}

+ (void)WebViewExposed_restartSession:(NSDictionary*)properties callback:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView && arView.arSession) {
        id configuration = [UADSARUtils createConfigurationFromProperties:[properties objectForKey:@"configuration"]];
        if (configuration) {
            arView.arConfiguration = configuration;
        } else {
            [callback error:@"Error creating configuration" arg1:nil];
            return;
        }

        NSNumber *runOptions = [properties objectForKey:@"runOptions"];
        if (runOptions) {
            arView.arRunOptions = (int)[runOptions integerValue];
        }

        [UADSARUtils arSessionRestart:arView.arSession
                    withConfiguration:arView.arConfiguration
                          withOptions:arView.arRunOptions];
        [callback invoke:nil];
    }
    else {
        [callback error:@"Error restarting session - No active ARView" arg1:nil];
    }
}

+ (void)WebViewExposed_setDepthFar:(NSNumber *)far
                          callback:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView) {
        arView.arFar = [far floatValue];
        [callback invoke:nil];
    }
    else {
        [callback error:@"Error setting far plane." arg1:nil];
    }
}

+ (void)WebViewExposed_setDepthNear:(NSNumber *)near
                           callback:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView) {
        arView.arNear = [near floatValue];
        [callback invoke:nil];
    }
    else {
        [callback error:@"Error setting near plane." arg1:nil];
    }
}

+ (void)WebViewExposed_showCameraFeed:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView) {
        arView.showCameraFeed = YES;
        [callback invoke:nil];
    } else {
        [callback error:@"ARView is null" arg1:nil];
    }
}

+ (void)WebViewExposed_hideCameraFeed:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView) {
        arView.showCameraFeed = NO;
        [callback invoke:nil];
    } else {
        [callback error:@"ARView is null" arg1:nil];
    }
}

+ (void)WebViewExposed_addAnchor:(NSString *)identifier
                      withMatrix:(NSString *)matrix
                        callback:(USRVWebViewCallback*)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView && arView.arSession) {
        [arView addAnchor:identifier withTransform:matrix];
        [callback invoke:nil];
    }
    else {
        [callback error:@"Error adding anchor." arg1:nil];
    }
}

+ (void)WebViewExposed_removeAnchor:(NSString *)identifier
                           callback:(USRVWebViewCallback*)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView && arView.arSession) {
        [arView removeAnchor:identifier];
        [callback invoke:nil];
    }
    else {
        [callback error:@"Error removing anchor." arg1:nil];
    }
}

+ (void)WebViewExposed_advanceFrame:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (arView && arView.arSession) {
        arView.drawNextCameraFrame = YES;
        [callback invoke:nil];
    }
    else {
        [callback error:@"Error during advanceFrame." arg1:nil];
    }
}

+ (void)WebViewExposed_getFrameInfo:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (!arView || !arView.arSession) {
        [callback error:@"No ARView or no session" arg1:nil];
        return;
    }

    id arFrame = [UADSARUtils sessionGetCurrentFrame:arView.arSession];
    if (!arFrame) {
        [callback error:@"No ARFrame yet." arg1:nil];
        return;
    }

    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CVPixelBufferRef videoFrame = [UADSARUtils arFrameCapturedImage:arFrame];
    size_t videoWidth = CVPixelBufferGetWidth(videoFrame);
    size_t videoHeight = CVPixelBufferGetHeight(videoFrame);
#if !TARGET_IPHONE_SIMULATOR
    CGAffineTransform t = [UADSARUtils arFrame:arFrame
                  displayTransformForOrientation:interfaceOrientation
                                        viewSize:[UADSARUtils sizeForOrientation:interfaceOrientation width:videoWidth height:videoHeight]];
#else
    CGAffineTransform t = CGAffineTransformIdentity;
#endif

    NSDictionary *frameInfo = @{
                                @"transform": @{
                                    @"a": FBOX(t.a),
                                    @"b": FBOX(t.b),
                                    @"c": FBOX(t.c),
                                    @"d": FBOX(t.d),
                                    @"tx": FBOX(t.tx),
                                    @"ty": FBOX(t.ty),
                                },
                                @"videoSize": @{
                                    @"width": FBOX(videoWidth),
                                    @"height": FBOX(videoHeight),
                                },
#if !TARGET_IPHONE_SIMULATOR
                                @"drawableSize": @{
                                    @"width": FBOX(arView.mtkView.drawableSize.width),
                                    @"height": FBOX(arView.mtkView.drawableSize.height),
                                },
#else
                                @"drawableSize": @{
                                    @"width": FBOX(0),
                                    @"height": FBOX(0),
                                },
#endif
                                @"interfaceOrientation": IBOX(interfaceOrientation),
                            };

    [callback invoke:frameInfo, nil];
}

+ (void)WebViewExposed_setFrameScaling:(NSDictionary *)frameScale
                              callback:(USRVWebViewCallback *)callback {
    UADSARView *arView = [UADSARView getInstance];
    if (!arView) {
        [callback error:@"No ARView" arg1:nil];
        return;
    }

    if ([frameScale objectForKey:@"scaleX"] && [frameScale objectForKey:@"scaleY"]) {
        @try {
            NSNumber *scaleX = [frameScale valueForKey:@"scaleX"];
            NSNumber *scaleY = [frameScale valueForKey:@"scaleY"];
            arView.arVideoScaleX = [scaleX floatValue];
            arView.arVideoScaleY = [scaleY floatValue];
        }
        @catch (NSException *exception) {
            [callback error:@"Error setting frame scaling" arg1:nil];
            return;
        }
    }

    if ([frameScale objectForKey:@"transform"]) {
        @try {
            NSDictionary *transform = [frameScale valueForKey:@"transform"];
            NSNumber *a, *b, *c, *d, *tx, *ty;
            a = [transform valueForKey:@"a"];
            b = [transform valueForKey:@"b"];
            c = [transform valueForKey:@"c"];
            d = [transform valueForKey:@"d"];
            tx = [transform valueForKey:@"tx"];
            ty = [transform valueForKey:@"ty"];
            CGAffineTransform t = CGAffineTransformMake([a floatValue], [b floatValue],
                                                        [c floatValue], [d floatValue],
                                                        [tx floatValue], [ty floatValue]);
            arView.arVideoTransform = t;
        }
        @catch (NSException *exception) {
            [callback error:@"Error setting frame scaling" arg1:nil];
            return;
        }
    }

    arView.arVideoScaled = YES;

    [callback invoke:nil];
}

@end
