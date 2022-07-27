
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**

   Log Level   Importance
   ________________________________________
   Fatal    One or more key business functionalities are not working and the whole system doesn’t fulfill the business functionalities.
   Error    One or more functionalities are not working, preventing some functionalities from working correctly.
   Warning    Unexpected behavior happened inside the application, but it is continuing its work and the key business features are operating as expected.
   Info    An event happened, the event is purely informative and can be ignored during normal operations.
   Debug   A log level used for events considered to be useful during software debugging when more granular information is needed.
   Trace    A log level describing events showing step by step execution of your code that can be ignored during the standard operation, but may be useful during extended debugging sessions.
 */


typedef NS_ENUM (NSInteger, UADSLogLevel) {
    kUADSLogLevelFatal,
    kUADSLogLevelError,
    kUADSLogLevelWarning,
    kUADSLogLevelInfo,
    kUADSLogLevelDebug,
    kUADSLogLevelTrace
};

extern NSString * uads_logLevelToString(UADSLogLevel type);

@protocol UADSLogRecord <NSObject>
- (NSString *)  system;     // serves for grouping of logs
- (NSString *)  message;     // the actual log
- (UADSLogLevel)level;
@end


@interface UADSLogRecordBase : NSObject<UADSLogRecord>
@property (nonatomic, readonly) NSString *system;
@property (nonatomic, readonly) NSString *message;
@property (nonatomic, readonly) UADSLogLevel type;

+ (instancetype)newWithSystem: (NSString *)system
                   andMessage: (NSString *)message
                     andLevel: (UADSLogLevel)level;

+ (instancetype)newWarning: (NSString *)message system: (NSString *)system;
+ (instancetype)newInfo: (NSString *)message system: (NSString *)system;
+ (instancetype)newError: (NSString *)message system: (NSString *)system;
+ (instancetype)newTrace: (NSString *)message system: (NSString *)system;
@end


@interface UADSDurationLogRecord : UADSLogRecordBase
+ (instancetype)newWith: (NSString *)message
                 system: (NSString *)category
               duration: (CFTimeInterval)duration;

@end

NS_ASSUME_NONNULL_END
