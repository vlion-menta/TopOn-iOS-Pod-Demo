//
//  AnyThinkMentaBiddingDelegate.h
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSplash/AnyThinkSplash.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaSplashBiddingDelegate : ATSplashCustomEvent

@property (nonatomic, strong)  NSString *placementID;

@property (nonatomic, assign) BOOL isReady;

@end

NS_ASSUME_NONNULL_END
