//
//  AnyThinkMentaNativeExpressCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaNativeCustomEventInland : ATNativeADCustomEvent <MentaUnifiedNativeExpressAdDelegate, MentaUnifiedNativeAdDelegate>

- (void)nativeExpressAdLoadedWith:(MentaUnifiedNativeExpressAd *)nativeExpressAd
               nativeExpressAdObj:(MentaUnifiedNativeExpressAdObject *)nativeExpressAdObj;

- (void)nativeAdLoadedWith:(MentaUnifiedNativeAd *)nativeAd
               nativeAdObj:(MentaNativeObject *)nativeObj;

@end

NS_ASSUME_NONNULL_END
