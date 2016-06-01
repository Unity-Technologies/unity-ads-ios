#import "UADSWebViewMethodInvokeOperation.h"

@interface UADSWebViewMethodInvokeQueue : NSObject

+ (void)addOperation:(UADSWebViewMethodInvokeOperation *)operation;

@end