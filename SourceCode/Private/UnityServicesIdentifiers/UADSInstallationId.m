#import "UADSInstallationId.h"
#import "UADSIdStore.h"
#import "UADSUnityPlayerPrefsStore.h"
#import "UADSUserDefaultsStore.h"

@interface UADSInstallationId ()

@property(nonatomic, strong) NSString *_Nullable savedInstallationId;
@property(nonatomic, strong) id<UADSIdStore> installationIdStore;
@property(nonatomic, strong) id<UADSIdStore> analyticsIdStore;
@property(nonatomic, strong) id<UADSIdStore> unityAdsIdStore;

@end

@implementation UADSInstallationId

+ (instancetype)shared {
  static UADSInstallationId *sharedInstance = nil;
  static dispatch_once_t onceToken;

  dispatch_once(&onceToken, ^{
    sharedInstance = [[UADSInstallationId alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init {
  // https://github.cds.internal.unity3d.com/unity/operate-services-sample/blob/c4fad12071bb3a74aa9631c7c4cce12112fd0156/ZippedPackages/com.unity.services.core-1.1.0-pre.8/Runtime/Device/InstallationId.cs
  UADSUnityPlayerPrefsStore *installationIdStore =
      [[UADSUnityPlayerPrefsStore alloc] initWithKey:@"UnityInstallationId"];
  UADSUnityPlayerPrefsStore *analyticsIdStore =
      [[UADSUnityPlayerPrefsStore alloc] initWithKey:@"unity.cloud_userid"];
  UADSUserDefaultsStore *unityAdsIdStore =
      [[UADSUserDefaultsStore alloc] initWithKey:@"unityads-idfi"];
  self = [self initWithInstallationIdStore:installationIdStore
                          analyticsIdStore:analyticsIdStore
                           unityAdsIdStore:unityAdsIdStore];
  return self;
}

- (instancetype)initWithInstallationIdStore:(id<UADSIdStore>)installationIdStore
                           analyticsIdStore:(id<UADSIdStore>)analyticsIdStore
                            unityAdsIdStore:(id<UADSIdStore>)unityAdsIdStore {
  self = [super init];

  if (self) {
    _installationIdStore = installationIdStore;
    _analyticsIdStore = analyticsIdStore;
    _unityAdsIdStore = unityAdsIdStore;

    [self readInstallationId];
    [self writeInstallationId];
  }

  return self;
}

- (NSString *)installationId {
  return self.savedInstallationId;
}

- (void)readInstallationId {
  // Check core services installation id
  NSString *installationId = [self.installationIdStore getValue];
  if (installationId) {
    self.savedInstallationId = installationId;
    return;
  }
  // Check analytics
  NSString *analyticsId = [self.analyticsIdStore getValue];
  if (analyticsId) {
    self.savedInstallationId = analyticsId;
    return;
  }
  // Check Unity Ads
  NSString *unityAdsId = [self.unityAdsIdStore getValue];
  if (unityAdsId) {
    self.savedInstallationId = unityAdsId;
    return;
  }

  // Generate id and write it to user defaults if none is found.
  NSString *generatedInstallationId = [[NSUUID UUID] UUIDString];
  self.savedInstallationId = generatedInstallationId;
}

- (void)writeInstallationId {
  [self.installationIdStore commitValue:self.savedInstallationId];
  [self.analyticsIdStore commitValue:self.savedInstallationId];
  [self.unityAdsIdStore commitValue:self.savedInstallationId];
}

@end
