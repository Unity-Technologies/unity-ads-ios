#import "UADSUnityPlayerPrefsStore.h"
#import "UADSPlist.h"

@interface UADSUnityPlayerPrefsStore ()

@property(nonatomic, strong) NSString *key;

@end

@implementation UADSUnityPlayerPrefsStore

- (instancetype)initWithKey:(NSString *)key {
  self = [super init];
  if (self) {
    _key = key;
  }
  return self;
}

- (NSString *_Nullable)getValue {
  NSDictionary *plistDictionary = [self plistDictionary];
  id value = [plistDictionary valueForKey:self.key];
  if (value && [value isKindOfClass:[NSString class]]) {
    return (NSString *)value;
  }

  return nil;
}

- (void)commitValue:(NSString *)value {
  NSDictionary *plistDictionary = [self plistDictionary];
  NSURL *plistFileUrl = [self plistFileUrl];

  if (plistFileUrl) {
    NSMutableDictionary *mutablePlistDictionary = [plistDictionary mutableCopy];
    [mutablePlistDictionary setValue:value forKey:self.key];
    [UADSPlist writePlist:mutablePlistDictionary toFileUrl:plistFileUrl];
  }
}

- (NSDictionary *)plistDictionary {
  NSURL *fileUrl = [self plistFileUrl];
  NSDictionary *plistDictionary = [UADSPlist dictionaryWithContentsOfURL:fileUrl];
  if (!plistDictionary) {
    return [[NSDictionary alloc] init];
  }

  return plistDictionary;
}

- (NSURL *_Nullable)plistFileUrl {
  NSURL *_Nullable url = [NSURL fileURLWithPath:[self plistFilePath]];
  return url;
}

// The file path According to the Unity PlayerPrefs Documenation :
// https://docs.unity3d.com/ScriptReference/PlayerPrefs.html
// ~/Library/Preferences/com.ExampleCompanyName.ExampleProductName.plist
- (NSString *_Nullable)plistFilePath {
  NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
  return [[NSString stringWithFormat:@"~/Library/Preferences/%@.plist", bundleIdentifier]
      stringByExpandingTildeInPath];
}

@end
