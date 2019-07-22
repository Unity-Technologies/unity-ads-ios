#import <Foundation/Foundation.h>
#import "USRVInitializationDelegate.h"

@protocol USRVInitializationNotificationCenterProtocol

-(void)addDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate;

-(void)removeDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate;

-(void)triggerSdkDidInitialize;

-(void)triggerSdkInitializeDidFail:(NSString *)message code:(int)code;

@end

@interface USRVInitializationNotificationCenter : NSObject <USRVInitializationNotificationCenterProtocol>

+(instancetype)sharedInstance;

-(void)addDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate;

-(void)removeDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate;

-(void)triggerSdkDidInitialize;

-(void)triggerSdkInitializeDidFail:(NSString *)message code:(int)code;

@end
