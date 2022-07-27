#import <Foundation/Foundation.h>
#import "USRVInitializationDelegate.h"
#import "UADSErrorState.h"

@protocol USRVInitializationNotificationCenterProtocol

- (void)addDelegate: (NSObject <USRVInitializationDelegate> *)delegate;

- (void)removeDelegate: (NSObject <USRVInitializationDelegate> *)delegate;

- (void)        triggerSdkDidInitialize;

- (void)triggerSdkInitializeDidFail: (NSString *)message code: (UADSErrorState)code;

@end

@interface USRVInitializationNotificationCenter : NSObject <USRVInitializationNotificationCenterProtocol>

+ (instancetype)sharedInstance;

- (void)addDelegate: (NSObject <USRVInitializationDelegate> *)delegate;

- (void)removeDelegate: (NSObject <USRVInitializationDelegate> *)delegate;

- (void)        triggerSdkDidInitialize;

- (void)triggerSdkInitializeDidFail: (NSString *)message code: (UADSErrorState)code;

@end
