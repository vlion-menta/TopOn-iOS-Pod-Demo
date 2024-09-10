//
//  AnyThinkMentaCustomEvent.h
//  AnyThinkSDKDemo
//
//  Created by jdy on 2024/4/11.
//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaSplashCustomEventInland : ATSplashCustomEvent <MentaUnifiedSplashAdDelegate>

@property (nonatomic, assign, readonly) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
