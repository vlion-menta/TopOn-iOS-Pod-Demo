//
//  AnyThinkMentaBiddingDelegate.m
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import "AnyThinkMentaSplashBiddingDelegate.h"
#import "AnyThinkMentaBiddingManager.h"
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@interface AnyThinkMentaSplashBiddingDelegate () <MentaMediationSplashDelegate>
@property (nonatomic, strong) NSString *biddingPrice;
@end

@implementation AnyThinkMentaSplashBiddingDelegate

// 广告素材加载成功
- (void)menta_splashAdDidLoad:(MentaMediationSplash *)splash {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告素材加载失败
- (void)menta_splashAdLoadFailedWithError:(NSError *)error splash:(MentaMediationSplash *)splash {
    self.isReady = NO;
    
    AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.placementID];
    // 返回获取竞价广告失败
    if (request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
    // 从biddingManager 移除bidding 代理。
    [[AnyThinkMentaBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.placementID];
    NSLog(@"------> didFailWithError bidding %@", error);
}

// 广告素材渲染成功
// 此时可以获取 ecpm
- (void)menta_splashAdRenderSuccess:(MentaMediationSplash *)splash {
    self.isReady = YES;
    double ecpm = splash.eCPM.doubleValue;
    if (ecpm > 0) {
        self.biddingPrice = [NSString stringWithFormat:@"%f", ecpm / 100.0];
    } else {
        self.biddingPrice = @"0";
    }
    
    // 拿到unitID的 ATTMBiddingRequest 对象
    AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.placementID];
    if (request.bidCompletion) {
        // 通过该方法告诉 我们SDK C2S竞价为多少，price：元(CN) or 美元(USD)，currencyType：币种
        // request.unitGroup.bidTokenTime :广告竞价超时时间
        // request.unitGroup.adapterClassString 自定义广告平台的文件名
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:self.biddingPrice
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime 
                                                     customObject:splash];
        // 绑定对应后台下发的 firm id
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        request.bidCompletion(bidInfo, nil);
    }
    NSLog(@"------> menta_splashAdDidLoad ");
}

// 广告素材渲染失败
- (void)menta_splashAdRenderFailureWithError:(NSError *)error splash:(MentaMediationSplash *)splash {
    self.isReady = NO;
    
    AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.placementID];
    // 返回获取竞价广告失败
    if (request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
    // 从biddingManager 移除bidding 代理。
    [[AnyThinkMentaBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.placementID];
    NSLog(@"------> didFailWithError bidding %@", error);
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
    // 从biddingManager 移除bidding 代理。
    [[AnyThinkMentaBiddingManager sharedInstance] removeBiddingDelegateWithUnitID:self.placementID];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}

@end
