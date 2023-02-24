#import "UADSUserDefaultsStore.h"

@interface UADSUserDefaultsStore ()

@property(nonatomic, strong) NSString *key;

@end

@implementation UADSUserDefaultsStore

- (instancetype)initWithKey:(NSString *)key {
  self = [super init];
  if (self) {
    _key = key;
  }
  return self;
}

- (NSString *_Nullable)getValue {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  return [userDefaults stringForKey:self.key];
}

- (void)commitValue:(NSString *)value {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  [userDefaults setObject:value forKey:self.key];
}

@end
