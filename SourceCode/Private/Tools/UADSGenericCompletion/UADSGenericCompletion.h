#import "UADSGenericError.h"
NS_ASSUME_NONNULL_BEGIN

#define SUCCESS_EMPTY(handler) [handler success: nil];

typedef void (^UADSErrorCompletion)(id<UADSError>);

/**
    Light Generic Class that provides unified callback API.
    it's initialized with two optional blocks for success and error and passed to a function
   @code
   typedef UADSGenericCompletion<NSString *> UADSStringCompletion;

   UADSStringCompletion *myCompletion =  [UADSStringCompletion newWithSuccess:^(NSString * _Nullable string) {
     // do smth with string
   } andError:^(id<UADSError> _Nonnull error) {
     // process error, or log error.errorString
   }];

   // then in a function we can call
   [completion success: myString];
   // or
   [completion success: OperationError];
 */


@interface UADSGenericCompletion<__covariant ObjectType> : NSObject
typedef void (^UADSSuccessCompletion)(_Nullable ObjectType);

+ (instancetype)newWithSuccess: (_Nullable UADSSuccessCompletion)success
                      andError: (_Nullable UADSErrorCompletion)error;

- (instancetype)initWithSuccess: (_Nullable UADSSuccessCompletion)success
                       andError: (_Nullable UADSErrorCompletion)error;
- (void)success: (_Nullable ObjectType)data;
- (void)error: (id<UADSError>)error;
@end

NS_ASSUME_NONNULL_END

typedef UADSGenericCompletion<id> UADSAnyCompletion;
