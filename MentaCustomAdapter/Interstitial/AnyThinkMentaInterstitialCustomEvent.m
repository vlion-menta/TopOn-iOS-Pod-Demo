//
//  AnyThinkMentaInterstitialCustomEvent.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaInterstitialCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"

@interface AnyThinkMentaInterstitialCustomEvent ()

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSString *biddingPrice;

@end

@implementation AnyThinkMentaInterstitialCustomEvent

/// 广告策略服务加载成功
- (void)menta_didFinishLoadingInterstitialADPolicy:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd {
    NSLog(@"------> %s", __FUNCTION__);
}

/// 插屏广告源数据拉取成功
- (void)menta_interstitialAdDidLoad:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd {
    NSLog(@"------> %s", __FUNCTION__);

}

/// 插屏广告视频下载成功
- (void)menta_interstitialAdMaterialDidLoad:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd {
    NSLog(@"------> %s", __FUNCTION__);
    self.isReady = YES;
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:self.biddingPrice
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:interstitialAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoaded:interstitialAd adExtra:nil];
    }
}

/// 插屏广告加载失败
- (void)menta_interstitialAd:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
    NSLog(@"------> %s", __FUNCTION__);
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        if (request.bidCompletion) {
            request.bidCompletion(nil, error);
        }
        [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
    } else {
        [self trackInterstitialAdLoadFailed:error];
    }
}

/// 插屏广告被点击了
- (void)menta_interstitialAdDidClick:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd {
    NSLog(@"------> %s", __FUNCTION__);
    self.closeType = ATAdCloseClickcontent;
    [self trackInterstitialAdClick];
}

/// 插屏广告关闭了
- (void)menta_interstitialAdDidClose:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd;{
    NSLog(@"------> %s", __FUNCTION__);
    [self trackInterstitialAdClose:@{kATADDelegateExtraDismissTypeKey: self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

/// 插屏将要展现
- (void)menta_interstitialAdWillVisible:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd {
    NSLog(@"------> %s", __FUNCTION__);

}

/// 插屏广告曝光
- (void)menta_interstitialAdDidExpose:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackInterstitialAdShow];
}

/// 插屏广告 展现的广告信息 曝光之前会触发该回调
- (void)menta_interstitialAd:(MentaUnifiedInterstitialAd *_Nonnull)interstitialAd bestTargetSourcePlatformInfo:(NSDictionary *_Nonnull)info {
    self.biddingPrice = [NSString stringWithFormat:@"%.2f",[info[@"BEST_SOURCE_PRICE"] doubleValue] / 100.0];
    NSLog(@"------> %s", __FUNCTION__);
}

- (void)dealloc {
    NSLog(@"------> %s", __FUNCTION__);
}

@end
