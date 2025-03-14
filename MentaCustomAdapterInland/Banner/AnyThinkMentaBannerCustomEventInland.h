//
//  AnyThinkMentaBannerCustomEvent.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import <AnyThinkBanner/AnyThinkBanner.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaBannerCustomEventInland : ATBannerCustomEvent <MentaUnifiedBannerAdDelegate>

@property (nonatomic, strong) NSString *UUID;

@end

NS_ASSUME_NONNULL_END
