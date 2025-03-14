//
//  AnyThinkMentaBiddingDelegate.m
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import "AnyThinkMentaSplashBiddingDelegateInland.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK-umbrella.h>
#import <MentaVlionBaseSDK/MentaVlionBaseSDK-umbrella.h>
#import "AnyThinkMentaBiddingManagerInland.h"

@interface AnyThinkMentaSplashBiddingDelegateInland () <MentaUnifiedSplashAdDelegate>
@property (nonatomic, strong) NSString *biddingPrice;
@end

@implementation AnyThinkMentaSplashBiddingDelegateInland

/// 开屏广告数据拉取成功
- (void)menta_splashAdDidLoad:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    self.isReady = YES;
    // 拿到unitID的 ATTMBiddingRequest 对象
    AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingManagerInland sharedInstance] getRequestItemWithUnitID:self.placementID];
    if (request.bidCompletion) {
        // 通过该方法告诉 我们SDK C2S竞价为多少，price：元(CN) or 美元(USD)，currencyType：币种
        // request.unitGroup.bidTokenTime :广告竞价超时时间
        // request.unitGroup.adapterClassString 自定义广告平台的文件名
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID 
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:self.biddingPrice
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime customObject:splashAd];
        // 绑定对应后台下发的 firm id
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        request.bidCompletion(bidInfo, nil);
    }
    MentaLog(@"------> menta_splashAdDidLoad ");
}

/// 开屏加载失败
- (void)menta_splashAd:(MentaUnifiedSplashAd *_Nonnull)splashAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
    self.isReady = NO;
    
    AnyThinkMentaBiddingRequestInland *request = [[AnyThinkMentaBiddingManagerInland sharedInstance] getRequestItemWithUnitID:self.placementID];
    // 返回获取竞价广告失败
    if (request.bidCompletion) {
        request.bidCompletion(nil, error);
    }
    // 从biddingManager 移除bidding 代理。
    [[AnyThinkMentaBiddingManagerInland sharedInstance] removeBiddingDelegateWithUnitID:self.placementID];
    MentaLog(@"------> didFailWithError bidding %@", error);
}

/// 开屏广告被点击了
- (void)menta_splashAdDidClick:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    [self trackSplashAdClick];
    MentaLog(@"------> menta_splashAdDidClick ");
}

/// 开屏广告关闭了
- (void)menta_splashAdDidClose:(MentaUnifiedSplashAd *_Nonnull)splashAd closeMode:(MentaSplashAdCloseMode)mode {
    [self trackSplashAdClosed:@{}];
    MentaLog(@"------> menta_splashAdDidClose ");
    // 从biddingManager 移除bidding 代理。
    [[AnyThinkMentaBiddingManagerInland sharedInstance] removeBiddingDelegateWithUnitID:self.placementID];
}

/// 开屏广告曝光
- (void)menta_splashAdDidExpose:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    [self trackSplashAdShow];
    MentaLog(@"------> menta_splashAdDidExpose ");
}

/// 广告策略服务加载成功
- (void)menta_didFinishLoadingADPolicy:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    MentaLog(@"------> menta_didFinishLoadingADPolicy ");
}

/// 开屏广告 展现的广告信息 曝光之后会触发该回调
- (void)menta_splashAd:(MentaUnifiedSplashAd *_Nonnull)splashAd bestTargetSourcePlatformInfo:(NSDictionary *_Nonnull)info {
    self.biddingPrice = [NSString stringWithFormat:@"%.2f",[info[@"BEST_SOURCE_PRICE"] doubleValue] / 100.0];
    MentaLog(@"------> bestTargetSourcePlatformInfo");
}

- (void)dealloc
{
    MentaLog(@"------> %s", __FUNCTION__);
}

@end
