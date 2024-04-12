//
//  AnyThinkMentaNativeExpressCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaNativeCustomEvent : ATNativeADCustomEvent <MentaUnifiedNativeExpressAdDelegate>

- (void)nativeExpressAdLoadedWith:(MentaUnifiedNativeExpressAd *)nativeExpressAd
               nativeExpressAdObj:(MentaUnifiedNativeExpressAdObject *)nativeExpressAdObj;

@end

NS_ASSUME_NONNULL_END
