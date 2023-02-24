#import "UADSPlist.h"

@implementation UADSPlist

+ (BOOL)writePlistIosEleven:(NSDictionary *)mutableDictionary
                  toFileUrl:(NSURL *)url API_AVAILABLE(ios(11)) {
  return [mutableDictionary writeToURL:url error:nil];
}

+ (BOOL)writePlistIosTen:(NSDictionary *)mutableDictionary toFileUrl:(NSURL *)url {
  return [mutableDictionary writeToURL:url atomically:YES];
}

+ (void)writePlist:(NSDictionary *)mutableDictionary toFileUrl:(NSURL *)url {
  if (@available(iOS 11.0, *)) {
    // We don't care if there is an error.
    [UADSPlist writePlistIosEleven:mutableDictionary toFileUrl:url];
  } else {
    [UADSPlist writePlistIosTen:mutableDictionary toFileUrl:url];
  }
}

+ (NSDictionary *_Nullable)dictionaryWithContentsOfURLIosEleven:(NSURL *)url
    API_AVAILABLE(ios(11)) {
  NSError *plistError;
  NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfURL:url error:&plistError];
  if (plistError) {
    return nil;
  }

  return plistDictionary;
}

+ (NSDictionary *_Nullable)dictionaryWithContentsOfURLIosTen:(NSURL *)url {
  NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfURL:url];

  return plistDictionary;
}

+ (NSDictionary *_Nullable)dictionaryWithContentsOfURL:(NSURL *)url {
  if (@available(iOS 11.0, *)) {
    return [UADSPlist dictionaryWithContentsOfURLIosEleven:url];
  } else {
    return [UADSPlist dictionaryWithContentsOfURLIosTen:url];
  }
}

@end
