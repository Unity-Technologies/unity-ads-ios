import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var interstitialButton: UIButton!
    @IBOutlet weak var initButton: UIButton!
    @IBOutlet weak var incentivizedButton: UIButton!
    @IBOutlet weak var gameIdTextField: UITextField!
    @IBOutlet weak var testModeButton: UIButton!
    
    let userDefaultsGameIdKey = "adsExampleAppGameId"
    let defaultGameId = "14850"

    var interstitialPlacementId = ""
    var incentivizedPlacementId = ""
    var testMode : Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (!UnityAds.isReady()) {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let gameId = defaults.stringForKey(userDefaultsGameIdKey) {
                gameIdTextField.text = gameId
            }
            else {
                gameIdTextField.text = defaultGameId
            }

            interstitialButton.enabled = false
            interstitialButton.backgroundColor = UIColor(red:0.13, green:0.17, blue:0.22, alpha:0.8)
            incentivizedButton.enabled = false
            incentivizedButton.backgroundColor = UIColor(red:0.13, green:0.17, blue:0.22, alpha:0.8)
            initButton.enabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions

    @IBAction func initButtonTapped(sender: AnyObject) {
        let gameId = gameIdTextField.text! != "" ? gameIdTextField.text! : defaultGameId

        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(gameId, forKey: userDefaultsGameIdKey)
        
        let mediationMetaData = UADSMediationMetaData.init()
        mediationMetaData.setName("mediationPartner")
        mediationMetaData.setVersion("v12345")
        mediationMetaData.setOrdinal(1)
        mediationMetaData.commit()

        initButton.enabled = false
        initButton.backgroundColor = UIColor(red:0.13, green:0.17, blue:0.22, alpha:0.8)
        gameIdTextField.enabled = false
        testModeButton.enabled = false
        UnityAds.setDebugMode(true);
        UnityAds.initialize(gameId, delegate: self, testMode: self.testMode)
    }
    
    @IBAction func interstitialButtonTapped(sender: AnyObject) {
        if (UnityAds.isReady()) {
            interstitialButton.enabled = false
            
            let playerMetaData = UADSPlayerMetaData.init()
            playerMetaData.setServerId("rikshot")
            playerMetaData.commit()
            
            UnityAds.show(self, placementId: interstitialPlacementId)
        }
    }
    
    @IBAction func incentivizedButtonTapped(sender: AnyObject) {
        if (UnityAds.isReady()) {
            incentivizedButton.enabled = false
            
            let playerMetaData = UADSPlayerMetaData.init()
            playerMetaData.setServerId("rikshot")
            playerMetaData.commit()
            
            UnityAds.show(self, placementId: incentivizedPlacementId)
        }
    }
    
    @IBAction func toggleTestMode(sender: AnyObject) {
        self.testMode = !self.testMode
        self.testModeButton.setTitle(self.testMode ? "ON" : "OFF", forState: .Normal)
    }
    
    @IBAction func doneEditingGameId(sender: AnyObject) {
        self.gameIdTextField?.resignFirstResponder()
    }
}


extension ViewController: UnityAdsDelegate {

    // MARK: UnityAdsDelegate
    
    func unityAdsReady(placementId: String) {
        print("UnityAds READY: " + placementId)
        
        switch placementId {
        case "video", "defaultZone", "defaultVideoAndPictureZone":
            interstitialPlacementId = placementId
            interstitialButton.enabled = true
            interstitialButton.backgroundColor = UIColor(red:0.13, green:0.59, blue:0.95, alpha:1.0)
            break;

        case "rewardedVideo", "rewardedVideoZone", "incentivizedZone":
            incentivizedPlacementId = placementId
            incentivizedButton.enabled = true
            incentivizedButton.backgroundColor = UIColor(red:0.13, green:0.59, blue:0.95, alpha:1.0)
            break;

        default:
            print("Unhandled placement id")
        }
    }
    
    func unityAdsDidStart(placementId: String) {
        print("UnityAds START: " + placementId)
    }
    
    func unityAdsDidError(error: UnityAdsError, withMessage message: String) {
        print("UnityAds ERROR: " + "\(error.rawValue) " + message);
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.initButton.enabled = true;
            if #available(iOS 8.0, *) {
                let alertController = UIAlertController(title: "UnityAds Error", message: "Error: " + "\(error.rawValue)" + " message: " + message, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    func unityAdsDidFinish(placementId: String, withFinishState state: UnityAdsFinishState) {
        var stateString = "UNKNOWN";
        if state == UnityAdsFinishState.Completed {
            stateString = "COMPLETED"
        } else if state == UnityAdsFinishState.Skipped {
            stateString = "SKIPPED"
        } else if state == UnityAdsFinishState.Error {
            stateString = "ERROR"
        }
        print("UnityAds FINISH: " + placementId + " - " + stateString)
    }
}