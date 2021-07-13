#import "ViewController.h"

static NSString *const kDefaultGameId = @"14850";
static NSString *const kGameIdKey = @"adsExampleAppGameId";
static int kMediationOrdinal = 1;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *interstitialButton;
@property (weak, nonatomic) IBOutlet UIButton *incentivizedButton;
@property (weak, nonatomic) IBOutlet UIButton *bannerButton;
@property (weak, nonatomic) IBOutlet UIButton *initializeButton;
@property (weak, nonatomic) IBOutlet UITextField *gameIdTextField;
@property (weak, nonatomic) IBOutlet UIButton *testModeButton;
@property (nonatomic, strong) UIView *bannerView;


@property (weak, nonatomic) NSString *defaultGameId;
@property (assign, nonatomic) BOOL testMode;
@property (copy, nonatomic) NSString *interstitialPlacementId;
@property (copy, nonatomic) NSString *incentivizedPlacementId;
@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    if (![UnityAds isReady]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        if ([defaults stringForKey: kGameIdKey]) {
            self.gameIdTextField.text = [defaults stringForKey: kGameIdKey];
        } else {
            self.gameIdTextField.text = kDefaultGameId;
        }
    }

    self.interstitialButton.enabled = NO;
    self.interstitialButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                              green: 0.17
                                                               blue: 0.22
                                                              alpha: 0.8];
    self.incentivizedButton.enabled = NO;
    self.incentivizedButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                              green: 0.17
                                                               blue: 0.22
                                                              alpha: 0.8];
    self.initializeButton.enabled = YES;
    self.bannerButton.enabled = NO;
    self.bannerButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                        green: 0.17
                                                         blue: 0.22
                                                        alpha: 0.8];
    self.testMode = YES;
} /* viewDidLoad */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneEditingGameId: (id)sender {
    [self.gameIdTextField resignFirstResponder];
}

- (IBAction)toggleTestMode: (id)sender {
    self.testMode = !self.testMode;
    [self.testModeButton setTitle: self.testMode ? @"ON" : @"OFF"
                         forState: UIControlStateNormal];
}

- (IBAction)incentivizedButtonTapped: (id)sender {
    if ([UnityAds isReady: self.incentivizedPlacementId]) {
        self.incentivizedButton.enabled = NO;
        UADSPlayerMetaData *playerMetaData = [[UADSPlayerMetaData alloc] init];
        [playerMetaData setServerId: @"rikshot"];
        [playerMetaData commit];

        UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setOrdinal: kMediationOrdinal++];
        [mediationMetaData commit];

        [UnityAds  show: self
            placementId: self.incentivizedPlacementId];
    }
}

- (IBAction)interstitialButtonTapped: (id)sender {
    if ([UnityAds isReady: self.interstitialPlacementId]) {
        self.interstitialButton.enabled = NO;
        UADSPlayerMetaData *playerMetaData = [[UADSPlayerMetaData alloc] init];
        [playerMetaData setServerId: @"rikshot"];
        [playerMetaData commit];
        UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];
        [mediationMetaData setOrdinal: kMediationOrdinal++];
        [mediationMetaData commit];

        [UnityAds  show: self
            placementId: self.interstitialPlacementId];
    }
}

- (IBAction)bannerButtonTapped: (id)sender {
    if ([self.bannerButton.titleLabel.text isEqualToString: @"Hide Banner"]) {
        // close banner
        [UnityAdsBanner destroy];
        self.bannerView = nil;
        [self.bannerButton setTitle: @"Show Banner"
                           forState: UIControlStateNormal];
    } else {
        // load banner
        [self.bannerButton setTitle: @"Hide Banner"
                           forState: UIControlStateNormal];
        [UnityAdsBanner setDelegate: self];
        [UnityAdsBanner setBannerPosition: kUnityAdsBannerPositionBottomCenter];
        [UnityAdsBanner loadBanner: @"bannerads"];
    }
}

- (IBAction)initializeButtonTapped: (id)sender {
    NSString *gameId = ![self.gameIdTextField.text isEqualToString: @""] ? self.gameIdTextField.text : kDefaultGameId;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject: gameId
                 forKey: kGameIdKey];

    // mediation
    UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];

    [mediationMetaData setName: @"mediationPartner"];
    [mediationMetaData setVersion: @"v12345"];
    [mediationMetaData commit];

    UADSMetaData *debugMetaData = [[UADSMetaData alloc] init];

    [debugMetaData set: @"test.debugOverlayEnabled"
                 value : @YES];
    [debugMetaData commit];

    self.initializeButton.enabled = NO;
    self.initializeButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                            green: 0.17
                                                             blue: 0.22
                                                            alpha: 0.8];
    self.gameIdTextField.enabled = NO;
    self.testModeButton.enabled = NO;
    self.bannerButton.enabled = YES;
    self.bannerButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                        green: 0.59
                                                         blue: 0.95
                                                        alpha: 1.0];

    [UnityAds setDebugMode: true];

    [UnityAds addDelegate: self];
    [UnityAds initialize: gameId
                      testMode: self.testMode
        initializationDelegate: self];
} /* initializeButtonTapped */

- (void)initializationComplete {
    NSLog(@"UnityAds initializationComplete");
}

- (void)initializationFailed: (UnityAdsInitializationError)error
                 withMessage: (NSString *)message {
    NSLog(@"UnityAds initializationFailed: %ld - %@", (long)error, message);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"UnityAds Error"
                                                                   message: [NSString stringWithFormat: @"%ld - %@", (long)error, message]
                                                            preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle: @"OK"
                                                     style: UIAlertActionStyleDefault
                                                   handler: ^(UIAlertAction *_Nonnull action) {
                                                   }];

    [alert addAction: action];
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
}

- (void)unityAdsReady: (NSString *)placementId {
    NSLog(@"UADS Ready");

    if ([placementId isEqualToString: @"video"] || [placementId isEqualToString: @"defaultZone"] || [placementId isEqualToString: @"defaultVideoAndPictureZone"]) {
        self.interstitialPlacementId = placementId;
        self.interstitialButton.enabled = YES;
        self.interstitialButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                                  green: 0.59
                                                                   blue: 0.95
                                                                  alpha: 1.0];
    }

    if ([placementId isEqualToString: @"rewardedVideo"] || [placementId isEqualToString: @"rewardedVideoZone"] || [placementId isEqualToString: @"incentivizedZone"]) {
        self.incentivizedPlacementId = placementId;
        self.incentivizedButton.enabled = YES;
        self.incentivizedButton.backgroundColor = [UIColor colorWithRed: 0.13
                                                                  green: 0.59
                                                                   blue: 0.95
                                                                  alpha: 1.0];
    }
} /* unityAdsReady */

- (void)unityAdsDidError: (UnityAdsError)error withMessage: (NSString *)message {
    NSLog(@"UnityAds ERROR: %ld - %@", (long)error, message);

    if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"UnityAds Error"
                                                                       message: [NSString stringWithFormat: @"%ld - %@", (long)error, message]
                                                                preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"OK"
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *_Nonnull action) {
                                                       }];
        [alert addAction: action];
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    }
}

- (void)unityAdsDidStart: (NSString *)placementId {
    NSLog(@"UADS Start");
}

- (void)unityAdsDidFinish: (NSString *)placementId withFinishState: (UnityAdsFinishState)state {
    NSString *stateString = @"UNKNOWN";

    switch (state) {
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
} /* unityAdsDidFinish */

#pragma mark : UnityAdsBannerDelegate

- (void)unityAdsBannerDidClick: (NSString *)placementId {
}

- (void)unityAdsBannerDidError: (NSString *)message {
}

- (void)unityAdsBannerDidHide: (NSString *)placementId {
}

- (void)unityAdsBannerDidLoad: (NSString *)placementId view: (UIView *)bannerView {
    ViewController *weakSelf = self;

    if (weakSelf) {
        [weakSelf.view addSubview: bannerView];
    }
}

- (void)unityAdsBannerDidShow: (NSString *)placementId {
}

@end