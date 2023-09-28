#import "GADQueryInfoBridge.h"
#import "UADSGenericCompletion.h"
#import "GMAScarSignalsReader.h"
#import "GMAScarSignalsReaderDecorator.h"
#import "UADSWebViewEventSender.h"
#import <UIKit/UIKit.h>
#import "GMAAdMetaData.h"
#import "UADSWebViewErrorHandler.h"
#import "GMAAdLoaderStrategy.h"
#import "UADSScarSignalParameters.h"

@interface UADSGMAScar : NSObject
@property (strong, nonatomic) id<UADSErrorHandler>errorHandler;
+ (instancetype) defaultInfo;
+ (UADSGMAScar *)sharedInstance;
- (instancetype)initWithEventSender: (id<UADSWebViewEventSender>)eventSender;

- (id<GMASCARSignalService>)rawSignalService;
- (NSString *)   sdkVersion;

- (BOOL)         isAvailable;
- (BOOL)         isGADSupported;
- (BOOL)         isGADExists;

- (void)getSCARSignals: (NSArray<UADSScarSignalParameters *>*) signalParameters
            completion: (UADSGMAEncodedSignalsCompletion *)completion;

- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta
              andCompletion: (UADSAnyCompletion *)completion;

- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController;

- (void)removeAdForPlacement:(NSString *)placementId;

// exposed for tests
- (id<GMAQueryInfoReader>)queryInfoReader;
@end
