#import "UADSInitializationResponse.h"
#import <Foundation/Foundation.h>
#import "UADSTools.h"
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSPrivacyResponseState) {
    kUADSPrivacyResponseUnknown,
    kUADSPrivacyResponseAllowed,
    kUADSPrivacyResponseDenied
};

NSString * uads_privacyResponseStateToString(UADSPrivacyResponseState);


@protocol UADSPrivacyResponseSaver <NSObject>

- (void)saveResponse: (UADSInitializationResponse *)response;

@end

@protocol UADSPrivacyResponseReader <NSObject>

- (UADSPrivacyResponseState)responseState;
- (BOOL)shouldSendUserNonBehavioral;

@end

@protocol UADSPrivacyResponseSubject <NSObject>
typedef void (^UADSPrivacyResponseObserver)(UADSInitializationResponse *);
- (void)subscribe: (UADSPrivacyResponseObserver)observer;
- (void)subscribeWithTimeout: (NSInteger)timeInSeconds
                 forObserver: (nonnull UADSPrivacyResponseObserver)observer
                     timeout: (UADSVoidClosure)timeout;
@end

@interface UADSPrivacyStorage : NSObject<UADSPrivacyResponseSaver, UADSPrivacyResponseReader, UADSPrivacyResponseSubject>

@end

NS_ASSUME_NONNULL_END
