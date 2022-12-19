
NS_ASSUME_NONNULL_BEGIN

@protocol UADSGADFullScreenContentDelegate <NSObject>
- (void)adDidPresentFullScreenContent: (id)ad;
- (void)ad: (id)ad didFailToPresentFullScreenContentWithError: (NSError *)error;
- (void)adDidDismissFullScreenContent: (id)ad;
- (void)adDidRecordImpression: (nonnull id)ad;
- (void)adDidRecordClick:(nonnull id)ad;
@end


NS_ASSUME_NONNULL_END
