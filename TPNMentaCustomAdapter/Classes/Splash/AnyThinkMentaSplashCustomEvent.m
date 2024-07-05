//
//  AnyThinkMentaCustomEvent.m
//  AnyThinkSDKDemo
//
//  Created by jdy on 2024/4/11.
//  Copyright © 2024 抽筋的灯. All rights reserved.
//

#import "AnyThinkMentaSplashCustomEvent.h"

@interface AnyThinkMentaSplashCustomEvent ()

@property (nonatomic, assign) BOOL isReady;

@end

@implementation AnyThinkMentaSplashCustomEvent

// 广告素材加载成功
- (void)menta_splashAdDidLoad:(MentaMediationSplash *)splash {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告素材加载失败
- (void)menta_splashAdLoadFailedWithError:(NSError *)error splash:(MentaMediationSplash *)splash {
    self.isReady = NO;
    [self trackSplashAdLoadFailed:error];
    NSLog(@"------> didFailWithError %@", error);
}

// 广告素材渲染成功
// 此时可以获取 ecpm
- (void)menta_splashAdRenderSuccess:(MentaMediationSplash *)splash {
    self.isReady = YES;
    [self trackSplashAdLoaded:splash];
    NSLog(@"------> menta_splashAdDidLoad ");
}

// 广告素材渲染失败
- (void)menta_splashAdRenderFailureWithError:(NSError *)error splash:(MentaMediationSplash *)splash {
    self.isReady = NO;
    [self trackSplashAdLoadFailed:error];
    NSLog(@"------> didFailWithError %@", error);
}

// 开屏广告即将展示
- (void)menta_splashAdWillPresent:(MentaMediationSplash *)splash {
    NSLog(@"------> %s", __FUNCTION__);
}

// 开屏广告展示失败
- (void)menta_splashAdShowFailWithError:(NSError *)error splash:(MentaMediationSplash *)splash {
    NSLog(@"------> %s", __FUNCTION__);
}

// 开屏广告曝光
- (void)menta_splashAdExposed:(MentaMediationSplash *)splash {
    [self trackSplashAdShow];
    NSLog(@"------> menta_splashAdDidExpose ");
}

// 开屏广告点击
- (void)menta_splashAdClicked:(MentaMediationSplash *)splash {
    [self trackSplashAdClick];
    NSLog(@"------> menta_splashAdDidClick ");
}

// 开屏广告关闭
-(void)menta_splashAdClosed:(MentaMediationSplash *)splash {
    [self trackSplashAdClosed:@{}];
    NSLog(@"------> menta_splashAdDidClose ");
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}


@end
