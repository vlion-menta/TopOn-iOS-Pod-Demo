//
//  AnyThinkMentaBannerCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import <AnyThinkBanner/AnyThinkBanner.h>
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaBannerCustomEvent : ATBannerCustomEvent <MentaMediationBannerDelegate>

@property (nonatomic, strong) NSString *UUID;

@end

NS_ASSUME_NONNULL_END
