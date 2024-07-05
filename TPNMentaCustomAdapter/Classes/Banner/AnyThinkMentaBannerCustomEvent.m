//
//  AnyThinkMentaBannerCustomEvent.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaBannerCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"

@interface AnyThinkMentaBannerCustomEvent ()

@property (nonatomic, strong) NSString *biddingPrice;

@end

@implementation AnyThinkMentaBannerCustomEvent

/// 广告策略服务加载成功
- (void)menta_didFinishLoadingBannerADPolicy:(MentaUnifiedBannerAd *_Nonnull)bannerAd {
    NSLog(@"------> %s", __FUNCTION__);
}

/// 横幅(banner)广告源数据拉取成功
- (void)menta_bannerAdDidLoad:(MentaUnifiedBannerAd *_Nonnull)bannerAd {
    NSLog(@"------> %s", __FUNCTION__);
}

/// 横幅(banner)广告物料下载成功
- (void)menta_bannerAdMaterialDidLoad:(MentaUnifiedBannerAd *_Nonnull)bannerAd {
    NSLog(@"------> %s", __FUNCTION__);
    if (self.isC2SBiding && [bannerAd fetchBannerView]) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.UUID];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:self.biddingPrice
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:bannerAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else if ([bannerAd fetchBannerView]) {
        [self trackBannerAdLoaded:bannerAd.fetchBannerView adExtra:nil];
    }
}

/// 横幅(banner)广告加载失败
- (void)menta_bannerAd:(MentaUnifiedBannerAd *_Nonnull)bannerAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
    NSLog(@"------> %s", __FUNCTION__);
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.UUID];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.UUID];
    } else {
        [self trackBannerAdLoadFailed:error];
    }
}

/// 横幅(banner)广告被点击了
- (void)menta_bannerAdDidClick:(MentaUnifiedBannerAd *_Nonnull)bannerAd adView:(UIView *_Nullable)adView {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackBannerAdClick];
}

/// 横幅(banner)广告关闭了
- (void)menta_bannerAdDidClose:(MentaUnifiedBannerAd *_Nonnull)bannerAd adView:(UIView *_Nullable)adView {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackBannerAdClosed];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.UUID];
}

/// 横幅(banner)将要展现
- (void)menta_bannerAdWillVisible:(MentaUnifiedBannerAd *_Nonnull)bannerAd adView:(UIView *_Nullable)adView {
    NSLog(@"------> %s", __FUNCTION__);
}

/// 横幅(banner)广告曝光
- (void)menta_bannerAdDidExpose:(MentaUnifiedBannerAd *_Nonnull)bannerAd adView:(UIView *_Nullable)adView {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackBannerAdImpression];
}

/// 横幅(banner)广告 展现的广告信息 曝光之前会触发该回调
- (void)menta_bannerAd:(MentaUnifiedBannerAd *_Nonnull)bannerAd bestTargetSourcePlatformInfo:(NSDictionary *_Nonnull)info {
    self.biddingPrice = [NSString stringWithFormat:@"%.2f",[info[@"BEST_SOURCE_PRICE"] doubleValue] / 100.0];
    NSLog(@"------> %s", __FUNCTION__);
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}


@end
