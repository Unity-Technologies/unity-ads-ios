#import "ViewController.h"
#import <UnityAds/UnityAds.h>

static NSString *const kDefaultGameId = @"14850";
static NSString *const kGameIdKey = @"adsExampleAppGameId";
static BOOL bannerShown = NO;

@interface ViewController ()
@property(weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property(weak, nonatomic) IBOutlet UIButton *incentivizedButton;
@property(weak, nonatomic) IBOutlet UIButton *bannerButton;
@property(weak, nonatomic) IBOutlet UIButton *initializeButton;
@property(weak, nonatomic) IBOutlet UITextField *gameIdTextField;
@property(weak, nonatomic) IBOutlet UIButton *testModeButton;

@property(weak, nonatomic) NSString *defaultGameId;
@property(assign, nonatomic) BOOL testMode;
@property UMONPlacementContent *incentivizedContent;
@property UMONPlacementContent *interstitialContent;
@property NSArray<NSString *> *interstitialPlacementIds;
@property NSArray<NSString *> *incentivizedPlacementIds;
@property(weak, nonatomic) NSString *bannerPlacementId;
@property(strong, nonatomic) UIView *bannerView;

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    if (![UnityAds isReady]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults stringForKey:kGameIdKey]) {
            self.gameIdTextField.text = [defaults stringForKey:kGameIdKey];
        } else {
            self.gameIdTextField.text = kDefaultGameId;
        }
    }

    self.interstitialButton.enabled = NO;
    self.interstitialButton.backgroundColor = [UIColor colorWithRed:0.13 green:0.17 blue:0.22 alpha:0.8];
    self.incentivizedButton.enabled = NO;
    self.incentivizedButton.backgroundColor = [UIColor colorWithRed:0.13 green:0.17 blue:0.22 alpha:0.8];
    self.initializeButton.enabled = YES;
    self.testMode = YES;

    self.interstitialPlacementIds = @[@"video", @"defaultZone", @"defaultVideoAndPictureZone"];
    self.incentivizedPlacementIds = @[@"rewardedVideo", @"rewardedVideoZone", @"incentivizedZone"];
    self.bannerPlacementId = @"banner";
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)doneEditingGameId:(id)sender {
    [self.gameIdTextField resignFirstResponder];
}

-(IBAction)toggleTestMode:(id)sender {
    self.testMode = !self.testMode;
    [self.testModeButton setTitle:self.testMode ? @"ON" : @"OFF" forState:UIControlStateNormal];
}

-(IBAction)incentivizedButtonTapped:(id)sender {
    [self showPlacementContent:self.incentivizedContent];
}

-(IBAction)interstitialButtonTapped:(id)sender {
    [self showPlacementContent:self.interstitialContent];
}

-(IBAction)bannerButtonTapped:(id)sender {
    [self showHideBanner:self.bannerPlacementId];
}

-(void)showPlacementContent:(UMONPlacementContent *)placementContent {
    if ([placementContent isKindOfClass:[UMONShowAdPlacementContent class]]) {
        [self showAdPlacementContent:(UMONShowAdPlacementContent *) placementContent];
    }
}

-(void)showAdPlacementContent:(UMONShowAdPlacementContent *)placementContent {
    [placementContent show:self withDelegate:self];
}

-(void)showHideBanner:(NSString *)placementId {
    if (bannerShown) {
        [UnityAdsBanner destroy];
    } else {
        [UnityAdsBanner loadBanner:placementId];
    }
}

-(IBAction)initializeButtonTapped:(id)sender {
    NSString *gameId = ![self.gameIdTextField.text isEqualToString:@""] ? self.gameIdTextField.text : kDefaultGameId;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:gameId forKey:kGameIdKey];

    // mediation
    UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
    [mediationMetaData setName:@"mediationPartner"];
    [mediationMetaData setVersion:@"v12345"];
    [mediationMetaData commit];

    self.initializeButton.enabled = NO;
    self.initializeButton.backgroundColor = [UIColor colorWithRed:0.13 green:0.17 blue:0.22 alpha:0.8];
    self.gameIdTextField.enabled = NO;
    self.testModeButton.enabled = NO;

    [UnityServices setDebugMode:YES];
    [UnityAdsBanner setDelegate:self];
    [UnityMonetization initialize:gameId delegate:self testMode:self.testMode];
}

-(void)placementContentReady:(NSString *)placementId placementContent:(UMONPlacementContent *)placementContent {
    if ([self.interstitialPlacementIds containsObject:placementId]) {
        self.interstitialContent = placementContent;
        [self enableButton:self.interstitialButton];
        [self updateButtonForContent:self.interstitialButton placementContent:placementContent];
    }
    if ([self.incentivizedPlacementIds containsObject:placementId]) {
        self.incentivizedContent = placementContent;
        [self enableButton:self.incentivizedButton];
        [self updateButtonForContent:self.incentivizedButton placementContent:placementContent];
    }
}

-(void)placementContentStateDidChange:(NSString *)placementId placementContent:(UMONPlacementContent *)decision previousState:(UnityMonetizationPlacementContentState)previousState newState:(UnityMonetizationPlacementContentState)newState {
    NSLog(@"State changed for %@ - %d - %d", placementId, previousState, newState);
}

-(void)enableButton:(UIButton *)btn {
    btn.enabled = YES;
    btn.backgroundColor = [UIColor colorWithRed:0.13 green:0.59 blue:0.95 alpha:1.0];
}

-(void)updateButtonForContent:(UIButton *)btn placementContent:(UMONPlacementContent *)placementContent {
    NSString *title;
    if ([placementContent isKindOfClass:[UMONShowAdPlacementContent class]]) {
        title = @"Show Ad";
        if (((UMONShowAdPlacementContent *) placementContent).rewarded) {
            title = [NSString stringWithFormat:@"%@ (Rewarded)", title];
        }
    }
    [btn setTitle:title forState:UIControlStateNormal];
}

#pragma mark : UnityAdsBannerDelegate

-(void)unityAdsBannerDidClick:(NSString *)placementId {

}

-(void)unityAdsBannerDidError:(NSString *)message {
    NSLog(@"UnityAdsBannerDidError: %@", message);
}

-(void)unityAdsBannerDidHide:(NSString *)placementId {
    bannerShown = NO;
}

-(void)unityAdsBannerDidLoad:(NSString *)placementId view:(UIView *)view {
    self.bannerView = view;
    [self.view addSubview:self.bannerView];
}

-(void)unityAdsBannerDidShow:(NSString *)placementId {
    bannerShown = YES;
}

-(void)unityAdsBannerDidUnload:(NSString *)placementId {
    bannerShown = NO;
    self.bannerView = nil;
}
-(void)unityAdsDidStart:(NSString *)placementId {
    NSLog(@"UnityAds START: %@", placementId);
}

-(void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)finishState {
    NSString *stateString = @"UNKNOWN";
    switch (finishState) {
        case kUnityAdsFinishStateError:
            stateString = @"ERROR";
            break;
        case kUnityAdsFinishStateSkipped:
            stateString = @"SKIPPED";
            break;
        case kUnityAdsFinishStateCompleted:
            stateString = @"COMPLETED";
            break;
        default:
            break;
    }
    NSLog(@"UnityAds FINISH: %@ - %@", stateString, placementId);
}
-(void)unityServicesDidError:(UnityServicesError)error withMessage:(NSString *)message {
    NSLog(@"UnityAds ERROR: %ld - %@",(long)error, message);
}


#pragma MARK : BYOP

@end

