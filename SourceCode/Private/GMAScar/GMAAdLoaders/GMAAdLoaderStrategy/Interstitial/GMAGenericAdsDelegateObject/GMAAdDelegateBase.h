#import <Foundation/Foundation.h>
#import "GMAAdMetaData.h"
#import "GADFullScreenContentDelegateProxy.h"
#import "UADSWebViewEventSender.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMAAdDelegateBase : NSObject<UADSGADFullScreenContentDelegate>
@property (nonatomic, strong) GMAAdMetaData *meta;
@property (nonatomic, strong) id<UADSWebViewEventSender>eventSender;
@property (nonatomic, strong) id<UADSErrorHandler>errorHandler;

+ (instancetype)newWithMetaData: (GMAAdMetaData *)meta
                andErrorHandler: (id<UADSErrorHandler>)errorHandler
                      andSender: (id<UADSWebViewEventSender>)eventSender
                  andCompletion: (UADSAnyCompletion *)completion;

- (void)didReceiveAd: (id)ad;

- (void)loadingOfAd: (id)ad
    failedWithError: (NSError *)error;

- (void)willPresentAd: (id)ad;

- (void)willDismissAd: (id)ad;

- (void)didDismissAd: (id)ad;

- (void)willLeaveApplication: (id)ad;
@end

NS_ASSUME_NONNULL_END
