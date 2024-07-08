//
//  AnyThinkMentaNativeExpressCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaNativeCustomEvent : ATNativeADCustomEvent <MentaMediationNativeExpressDelegate, MentaNativeSelfRenderDelegate>

- (void)nativeExpressAdLoadedWith:(MentaMediationNativeExpress *)nativeExpresAd
              nativeExpressAdView:(UIView *)nativeExpressAdView;

- (void)nativeSelfRenderAdLoadedWith:(MentaMediationNativeSelfRender *)nativeSelfRenderAd
             nativeSelfRenderAdModel:(MentaMediationNativeSelfRenderModel *)nativeSelfRenderAdModel;

@end

NS_ASSUME_NONNULL_END
