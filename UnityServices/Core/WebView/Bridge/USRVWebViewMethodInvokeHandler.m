#import "USRVWebViewMethodInvokeHandler.h"
#import "USRVInvocation.h"
#import "USRVWebViewCallback.h"
#import "USRVWebViewBridge.h"

@implementation USRVWebViewMethodInvokeHandler

- (void)handleData:(NSData *)jsonData invocationType:(NSString *)invocationType {
    NSError *jsonError;
    
    if (invocationType) {
        if ([invocationType isEqualToString:@"handleInvocation"]) {
            NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (jsonError) {
                USRVLogError(@"JSON ERROR: %@", [jsonError description]);
            }
            else if (!jsonArray || ![jsonArray isKindOfClass:[NSArray class]]) {
                USRVLogError(@"ERROR PARSING JSON TO ARRAY: %@", jsonError);
                return;
            }
            
            [self handleInvocation:jsonArray];
        }
        else if ([invocationType isEqualToString:@"handleCallback"]) {
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (jsonError) {
                USRVLogError(@"JSON ERROR: %@", [jsonError description]);
            }
            else if (!jsonDictionary || ![jsonDictionary isKindOfClass:[NSDictionary class]]) {
                USRVLogError(@"ERROR PARSING JSON TO DICTIONARY: %@", jsonError);
                return;
            }
            
            [self handleCallback:jsonDictionary];
        }
    }
}

- (void)handleInvocation:(NSArray *)invocations {
    USRVInvocation *batch = [[USRVInvocation alloc] init];
    
    USRVLogDebug(@"%@", invocations);
    NSMutableDictionary *failedIndices = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *failedCallbacks = [[NSMutableDictionary alloc] init];
    
    for (int idx = 0; idx < [invocations count]; idx++) {
        NSArray* invocation = [invocations objectAtIndex:idx];
        NSString *className = [invocation objectAtIndex:0];
        NSString *methodName = [invocation objectAtIndex:1];
        NSArray *parameters = [invocation objectAtIndex:2];
        
        if (!parameters || ![parameters isKindOfClass:[NSArray class]]) {
            NSException* exception = [NSException
                                      exceptionWithName:@"InvalidInvocationException"
                                      reason:@"Parameters NULL or not NSArray"
                                      userInfo:nil];
            @throw exception;
        }
        
        NSString *callback = [invocation objectAtIndex:3];
        USRVWebViewCallback *webViewCallback = [[USRVWebViewCallback alloc] initWithCallbackId:callback invocationId:[batch invocationId]];
        
        @try {
            [batch addInvocation:className methodName:methodName parameters:parameters callback:webViewCallback];
        }
        @catch (NSException *exception) {
            USRVLogError(@"Error while adding invocation: %@", [exception reason]);
            [failedIndices setObject:exception forKey:[NSNumber numberWithInt:idx]];
            [failedCallbacks setObject:webViewCallback forKey:[NSNumber numberWithInt:idx]];
        }
    }
    
    for (int idx = 0; idx < [invocations count]; idx++) {
        if ([failedIndices objectForKey:[NSNumber numberWithInt:idx]]) {
            NSException *exception = [failedIndices objectForKey:[NSNumber numberWithInt:idx]];
            USRVWebViewCallback *webViewCallback = [failedCallbacks objectForKey:[NSNumber numberWithInt:idx]];
            
            if (webViewCallback) {
                [webViewCallback error:[exception name] arg1:[exception reason], nil];
            }
        }
        else {
            [batch nextInvocation];
        }
    }
    
    [batch sendInvocationCallback];
}

- (void)handleCallback:(NSDictionary *)callback {
    NSString *callbackId = [callback objectForKey:@"id"];
    NSString *callbackStatus = [callback objectForKey:@"status"];
    id parameters = [callback objectForKey:@"parameters"];
    NSError *jsonError;

    if ([parameters isKindOfClass:[NSString class]]) {
        USRVLogDebug(@"Found NSString instead of NSArray, trying to convert");
        parameters = [NSJSONSerialization JSONObjectWithData:[[callback objectForKey:@"parameters"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&jsonError];
    }

    if (jsonError || !parameters || ![parameters isKindOfClass:[NSArray class]]) {
        NSException* exception = [NSException
                                  exceptionWithName:@"InvalidArgumentException"
                                  reason:@"Parameters NULL or wrong format"
                                  userInfo:nil];
        @throw exception;
    }

    [USRVWebViewBridge handleCallback:callbackId callbackStatus:callbackStatus params:parameters];
}


@end
