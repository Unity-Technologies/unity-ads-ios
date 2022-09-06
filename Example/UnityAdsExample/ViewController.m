#import "ViewController.h"
#import "USRVDeviceLog.h"
static NSString *const kDefaultGameId = @"14850";
static NSString *const kGameIdKey = @"adsExampleAppGameId";

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *interstitialLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *interstitialShowButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedLoadButton;
@property (weak, nonatomic) IBOutlet UIButton *rewardedShowButton;
@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *initializeButton;
@property (weak, nonatomic) IBOutlet UITextField *gameIdTextField;
@property (weak, nonatomic) IBOutlet UIView *gameIdView;
@property (weak, nonatomic) IBOutlet UIView *testModeView;
@property (weak, nonatomic) IBOutlet UISwitch *testModeSwitch;

@property (weak, nonatomic) NSString *defaultGameId;
@property (assign, nonatomic) BOOL testMode;
@property (copy, nonatomic) NSString *interstitialPlacementId;
@property (copy, nonatomic) NSString *rewardedPlacementId;

@property (copy, nonatomic) NSString *bannerId;
@property (strong, nonatomic) UADSBannerView *bannerView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if ([defaults stringForKey: kGameIdKey]) {
        self.gameIdTextField.text = [defaults stringForKey: kGameIdKey];
    } else {
        self.gameIdTextField.text = kDefaultGameId;
    }

    self.interstitialPlacementId = [defaults valueForKey:@"interstitialPlacementId"] ?:  @"video";
    self.rewardedPlacementId = @"rewardedVideo";
    self.bannerId = @"bannerads";
    self.testMode = YES;
    
    self.initializeButton.accessibilityIdentifier = @"InitializeButton";
    self.gameIdTextField.accessibilityIdentifier = @"GameIDField";
    self.interstitialLoadButton.accessibilityIdentifier = @"interstitialLoadButton";
    self.interstitialShowButton.accessibilityIdentifier = @"interstitialShowButton";
    
} /* viewDidLoad */

- (IBAction)doneEditingGameId: (id)sender {
    [self.gameIdTextField resignFirstResponder];
}

- (IBAction)toggleTestMode: (id)sender {
    self.testMode = self.testModeSwitch.on;
}

- (IBAction)initializeButtonTapped: (id)sender {
    NSString *gameId = ![self.gameIdTextField.text isEqualToString: @""] ? self.gameIdTextField.text : kDefaultGameId;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject: gameId
                 forKey: kGameIdKey];

    [self toggleButtons: @[self.initializeButton]
                enabled: NO];

    self.gameIdTextField.enabled = NO;
    self.testModeSwitch.enabled = NO;

    [UnityAds setDebugMode: false];
    [USRVDeviceLog setLogLevel: -1];
    [UnityAds initialize: gameId
                      testMode: self.testMode
        initializationDelegate: self];
    [USRVDeviceLog setLogLevel: -1];
} /* initializeButtonTapped */

- (IBAction)interstitialLoadButtonTapped: (id)sender {
    [UnityAds   load: self.interstitialPlacementId
        loadDelegate: self];
}

- (IBAction)rewardedLoadButtonTapped: (id)sender {
    [UnityAds   load: self.rewardedPlacementId
        loadDelegate: self];
}

- (IBAction)interstitialShowButtonTapped: (id)sender {
    [UnityAds   show: self
         placementId: self.interstitialPlacementId
        showDelegate: self];
}

- (IBAction)rewardedShowButtonTapped: (id)sender {
    [UnityAds   show: self
         placementId: self.rewardedPlacementId
        showDelegate: self];
}

- (IBAction)bannerButtonTapped: (id)sender {
    if ([self.bannerButton.titleLabel.text isEqualToString: @"Hide Banner"]) {
        // close banner
        [self.bannerButton setTitle: @"Show Banner"
                           forState: UIControlStateNormal];

        [self.bannerView removeFromSuperview];
        self.bannerView = nil;
    } else {
        // load banner
        [self.bannerButton setTitle: @"Hide Banner"
                           forState: UIControlStateNormal];

        self.bannerView = [[UADSBannerView alloc] initWithPlacementId: self.bannerId
                                                                 size: CGSizeMake(320, 50)];
        self.bannerView.delegate = self;
        [self addBannerViewToBottomView: self.bannerView];
        [self.bannerView load];
    }
}

- (void)enableLoad: (BOOL)loadEnabled show: (BOOL)showEnabled forPlacementId: (NSString *)placementId {
    if ([placementId isEqualToString: self.interstitialPlacementId]) {
        [self toggleButtons: @[self.interstitialShowButton]
                    enabled: showEnabled];
        [self toggleButtons: @[self.interstitialLoadButton]
                    enabled: loadEnabled];
    } else if ([placementId isEqualToString: self.rewardedPlacementId]) {
        [self toggleButtons: @[self.rewardedShowButton]
                    enabled: showEnabled];
        [self toggleButtons: @[self.rewardedLoadButton]
                    enabled: loadEnabled];
    }
}

#pragma mark UnityAdsInitializationDelegate

- (void)initializationComplete {
    NSLog(@"UnityAds initializationComplete");

    [self toggleButtons: @[self.interstitialLoadButton, self.rewardedLoadButton, self.bannerButton]
                enabled: YES];
}

- (void)initializationFailed: (UnityAdsInitializationError)error
                 withMessage: (NSString *)message {
    NSLog(@"UnityAds initializationFailed: %ld - %@", (long)error, message);
}

#pragma mark UnityAdsLoadDelegate

- (void)unityAdsAdLoaded: (NSString *)placementId {
    NSLog(@"UnityAds adLoaded");

    [self   enableLoad: NO
                  show: YES
        forPlacementId: placementId];
}

- (void)unityAdsAdFailedToLoad: (NSString *)placementId withError: (UnityAdsLoadError)error withMessage: (NSString *)message {
    NSLog(@"UnityAds adFailedToLoad: %ld - %@", (long)error, message);
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"My Alert"
                                   message:message
                                   preferredStyle:UIAlertControllerStyleAlert];
     
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
       handler:^(UIAlertAction * action) {}];
     
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

#pragma mark UnityAdsShowDelegate
- (void)unityAdsShowComplete: (NSString *)placementId withFinishState: (UnityAdsShowCompletionState)state {
    NSLog(@"UnityAds showComplete %@ %ld", placementId, state);

    [self   enableLoad: YES
                  show: NO
        forPlacementId: placementId];
}

- (void)unityAdsShowFailed: (NSString *)placementId withError: (UnityAdsShowError)error withMessage: (NSString *)message {
    NSLog(@"UnityAds showFailed %@ %ld", message, error);

    [self   enableLoad: YES
                  show: NO
        forPlacementId: placementId];
}

- (void)unityAdsShowStart: (NSString *)adUnitId {
    NSLog(@"UnityAds showStart %@", adUnitId);
}

- (void)unityAdsShowClick: (NSString *)adUnitId {
    NSLog(@"UnityAds showClick %@", adUnitId);
}

#pragma mark : UADSBannerViewDelegate

- (void)bannerViewDidLoad: (UADSBannerView *)bannerView {
    // Called when the banner view object finishes loading an ad.
    NSLog(@"UnityAds Banner loaded for placement: %@", bannerView.placementId);
}

- (void)bannerViewDidClick: (UADSBannerView *)bannerView {
    // Called when the banner is clicked.
    NSLog(@"UnityAds Banner was clicked for placement: %@", bannerView.placementId);
}

- (void)bannerViewDidLeaveApplication: (UADSBannerView *)bannerView {
    // Called when the banner links out of the application.
}

- (void)bannerViewDidError: (UADSBannerView *)bannerView error: (UADSBannerError *)error {
    NSLog(@"UnityAds Banner encountered an error for placement: %@ with error message %@", bannerView.placementId, [error localizedDescription]);
}

#pragma mark Helpers

- (void)setupUI {
    [self addBorder: self.gameIdView];
    [self addBorder: self.testModeView];

    [self toggleButtons: @[self.interstitialLoadButton, self.interstitialShowButton, self.rewardedLoadButton, self.rewardedShowButton, self.bannerButton]
                enabled: false];
}

- (void)addBorder: (UIView *)subview {
    subview.layer.borderWidth = 2.0;
    subview.layer.borderColor = [[UIColor darkGrayColor] CGColor];
}

- (void)toggleButtons: (NSArray *)buttons enabled: (BOOL)enabled {
    for (UIButton *button in buttons) {
        button.enabled = enabled;
        button.backgroundColor = enabled ? [UIColor colorWithRed: 0.13
                                                           green: 0.59
                                                            blue: 0.95
                                                           alpha: 1.0] : [UIColor colorWithRed: 0.13
                                                                                         green: 0.17
                                                                                          blue: 0.22
                                                                                         alpha: 0.8];
    }
}

- (void)addBannerViewToBottomView: (UIView *)bannerView {
    bannerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview: bannerView];
    [self.view addConstraints: @[
         [NSLayoutConstraint constraintWithItem: bannerView
                                      attribute: NSLayoutAttributeBottom
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self.bottomLayoutGuide
                                      attribute: NSLayoutAttributeTop
                                     multiplier: 1
                                       constant: 0],
         [NSLayoutConstraint constraintWithItem: bannerView
                                      attribute: NSLayoutAttributeCenterX
                                      relatedBy: NSLayoutRelationEqual
                                         toItem: self.view
                                      attribute: NSLayoutAttributeCenterX
                                     multiplier: 1
                                       constant: 0]
    ]];
}

@end
