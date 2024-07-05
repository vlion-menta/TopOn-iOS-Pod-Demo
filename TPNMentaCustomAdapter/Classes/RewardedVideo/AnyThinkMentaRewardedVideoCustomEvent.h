//
//  AnyThinkMentaRewardedVideoCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import <AnyThinkRewardedVideo/AnyThinkRewardedVideo.h>
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaRewardedVideoCustomEvent : ATRewardedVideoCustomEvent <MentaMediationRewardVideoDelegate>

@property (nonatomic, assign, readonly) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
