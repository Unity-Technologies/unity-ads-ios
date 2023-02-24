#import "UADSSessionId.h"
#import "UADSIdStore.h"
#import "UADSUnityPlayerPrefsStore.h"
#import "UADSUserDefaultsStore.h"

@interface UADSSessionId ()

@property(nonatomic, strong) NSString *_Nullable currentSessionId;

@end

@implementation UADSSessionId

+ (instancetype)shared {
  static UADSSessionId *sharedInstance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    sharedInstance = [[UADSSessionId alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _currentSessionId = [[NSUUID UUID] UUIDString];
  }
  return self;
}

- (NSString *)sessionId {
  return self.currentSessionId;
}

@end
