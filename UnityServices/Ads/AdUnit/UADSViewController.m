#import "UADSViewController.h"
#import "USRVWebViewApp.h"
#import "UADSAdUnitEvent.h"
#import "USRVWebViewEventCategory.h"
#import "UADSApiWebPlayer.h"
#import "USRVModuleConfiguration.h"
#import "UADSAdsModuleConfiguration.h"
#import "UnityAds.h"
#import <sys/utsname.h>

@interface UADSViewController ()
@property (atomic, strong) NSMutableDictionary<NSString*, UADSAdUnitViewHandler*> *viewHandlers;
@end

@implementation UADSViewController

- (instancetype)initWithViews:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(BOOL)statusBarHidden shouldAutorotate:(BOOL)shouldAutorotate isTransparent:(BOOL)isTransparent homeIndicatorAutoHidden:(BOOL)homeIndicatorAutoHidden {
    self = [super init];

    if (self) {
        [self setTransparent:isTransparent];
        [self setCurrentViews:views];
        [self setStatusBarHidden:statusBarHidden];
        [self setSupportedOrientations:[supportedOrientations intValue]];
        [self setAutorotate:shouldAutorotate];
        [self setHomeIndicatorAutoHidden:homeIndicatorAutoHidden];
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerInit) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAdunit) param1:nil];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[self isTransparent] ? [UIColor clearColor] : [UIColor blackColor]];

    if (_viewHandlers) {
        for (NSString *key in _viewHandlers) {
            UADSAdUnitViewHandler *viewHandler = [_viewHandlers objectForKey:key];
            if (viewHandler) {
                [viewHandler viewDidLoad:self];
            }
        }
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidLoad) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAdunit) param1:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setViews:self.currentViews];

    if (_viewHandlers) {
        for (NSString *key in _viewHandlers) {
            UADSAdUnitViewHandler *viewHandler = [_viewHandlers objectForKey:key];
            if (viewHandler) {
                [viewHandler viewDidAppear:self animated:animated];
            }
        }
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidAppear) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAdunit) param1:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setViews:self.currentViews];
    
    if (_viewHandlers) {
        for (NSString *key in _viewHandlers) {
            UADSAdUnitViewHandler *viewHandler = [_viewHandlers objectForKey:key];
            if (viewHandler) {
                [viewHandler viewWillAppear:self animated:animated];
            }
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    if (_viewHandlers) {
        for (NSString *key in _viewHandlers) {
            UADSAdUnitViewHandler *viewHandler = [_viewHandlers objectForKey:key];
            if (viewHandler) {
                [viewHandler viewWillDisappear:self animated:animated];
            }
        }
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerWillDisappear) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAdunit) param1:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (_viewHandlers) {
        for (NSString *key in _viewHandlers) {
            UADSAdUnitViewHandler *viewHandler = [_viewHandlers objectForKey:key];
            if (viewHandler) {
                [viewHandler viewDidDisappear:self animated:animated];
            }
        }
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidDisappear) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAdunit) param1:nil];
}

- (void)setViewFrame:(NSString *)view x:(int)x y:(int)y width:(int)width height:(int)height {
    UADSAdUnitViewHandler *viewHandler = [self getViewHandler:view];
    UIView *targetView = NULL;
    

    if ([view isEqualToString:@"adunit"]) {
        targetView = self.view;
    }
    else if (viewHandler) {
        targetView = [viewHandler getView];
    }

    if (targetView) {
        [targetView setFrame:CGRectMake(x, y, width, height)];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.supportedOrientations;
}

- (BOOL)shouldAutorotate {
    return self.autorotate;
}

- (void)setSupportedOrientations:(int)supportedOrientations {
    _supportedOrientations = supportedOrientations;
    [self.view setNeedsLayout];
}

- (void)setStatusBarHidden:(BOOL)statusBarHidden {
    _statusBarHidden = statusBarHidden;
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)setTransparent:(BOOL)isTransparent {
    _transparent = isTransparent;
}

- (void)setTransform:(float)transform {
    self.view.transform = CGAffineTransformMakeRotation(transform);
}

- (void)setHomeIndicatorAutoHidden:(BOOL)homeIndicatorAutoHidden {
    _homeIndicatorAutoHidden = homeIndicatorAutoHidden;
    
    SEL setNeedsUpdateOfHomeIndicatorAutoHiddenSelector = NSSelectorFromString(@"setNeedsUpdateOfHomeIndicatorAutoHidden");
    if([self respondsToSelector:setNeedsUpdateOfHomeIndicatorAutoHiddenSelector]) {
        IMP setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorImp = [self methodForSelector:setNeedsUpdateOfHomeIndicatorAutoHiddenSelector];
        if (setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorImp) {
            void (*setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorFunc)(id, SEL) = (void *)setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorImp;
            setNeedsUpdateOfHomeIndicatorAutoHiddenSelectorFunc(self, setNeedsUpdateOfHomeIndicatorAutoHiddenSelector);
        }
    }
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarHidden;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return self.homeIndicatorAutoHidden;
}

- (BOOL)isTransparent {
    return _transparent;
}

- (void)setViews:(NSArray<NSString*>*)views {
    NSMutableArray<NSString*>* actualViews = NULL;

    if (views == NULL) {
        actualViews = [[NSMutableArray alloc] init];
    }
    else {
        actualViews = [[NSMutableArray alloc] init];
        [actualViews addObjectsFromArray:views];
    }
    
    if (!_currentViews) {
        _currentViews = [[NSArray alloc] init];
    }
    
    NSMutableArray<NSString*>* newViews = [[NSMutableArray alloc] init];
    [newViews addObjectsFromArray:actualViews];
    NSMutableArray<NSString*>* removedViews = [[NSMutableArray alloc] init];
    [removedViews addObjectsFromArray:_currentViews];
    [removedViews removeObjectsInArray:newViews];

    for (NSString *view in removedViews) {
        if (view == NULL) {
            continue;
        }

        UADSAdUnitViewHandler *viewHandler = [self getViewHandler:view];
        [viewHandler destroy];
    }

    for (NSString *view in actualViews) {
        if (view == NULL) {
            continue;
        }
        
        UADSAdUnitViewHandler *viewHandler = [self getViewHandler:view];
        [viewHandler create:self];
        [self handleViewPlacement:[viewHandler getView]];
    }

    _currentViews = [[NSArray alloc] initWithArray:actualViews copyItems:true];
}

- (void)handleViewPlacement:(UIView *)view {
    if ([view superview] && [[view superview] isEqual:self.view]) {
        USRVLogDebug(@"Bringing to front: %@", view);
        [self.view bringSubviewToFront:view];
    }
    else {
        if ([view superview]) {
            [view removeFromSuperview];
        }

        [view setHidden:false];
        [view setCenter:[self.view convertPoint:self.view.center fromView:self.view.superview]];
        [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        USRVLogDebug(@"Adding to view: %@", view);
        [self.view addSubview:view];
    }
    [view setFrame:[self getRect]];
}

- (UADSAdUnitViewHandler *)getViewHandler:(NSString *)viewName {
    UADSAdUnitViewHandler *viewHandler;
    
    if (_viewHandlers && [_viewHandlers objectForKey:viewName]) {
        viewHandler = [_viewHandlers objectForKey:viewName];
    }
    else {
        viewHandler = [self createViewHandler:viewName];
        
        if (viewHandler) {
            if (!_viewHandlers) {
                _viewHandlers = [[NSMutableDictionary alloc] init];
            }
            
            [_viewHandlers setObject:viewHandler forKey:viewName];
        }
    }
    
    return viewHandler;
}

- (UADSAdUnitViewHandler *)createViewHandler:(NSString *)viewName {
    if ([USRVWebViewApp getCurrentApp]) {
        USRVConfiguration *configuration = [[USRVWebViewApp getCurrentApp] configuration];
        NSArray<NSString*> *moduleConfigurationList = [configuration getModuleConfigurationList];
        
        for (NSString *moduleName in moduleConfigurationList) {
            USRVModuleConfiguration *moduleConfiguration = [configuration getModuleConfiguration:moduleName];
            if ([moduleConfiguration isKindOfClass:[UADSAdsModuleConfiguration class]]) {
                NSDictionary<NSString*, NSString*> *adUnitViewHandlers = [((UADSAdsModuleConfiguration *)moduleConfiguration) getAdUnitViewHandlers];
                if (adUnitViewHandlers && [adUnitViewHandlers objectForKey:viewName]) {
                    UADSAdUnitViewHandler *viewHandler = [[NSClassFromString([adUnitViewHandlers objectForKey:viewName]) alloc] init];
                    return viewHandler;
                }
            }
        }
    }
    
    return NULL;
}

- (CGRect)getRect {
    CGFloat x = CGRectGetMinX(self.view.bounds);
    CGFloat y = CGRectGetMinY(self.view.bounds);
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat height = CGRectGetHeight(self.view.bounds);
    
    return CGRectMake(x, y, width, height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromAdUnitEvent(kUnityAdsViewControllerDidReceiveMemoryWarning) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAdunit) param1:nil];
}
@end
