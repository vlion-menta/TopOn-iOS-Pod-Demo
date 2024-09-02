//
//  AnyThinkMentaRewardedVideoCustomEvent.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaRewardedVideoCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>

@interface AnyThinkMentaRewardedVideoCustomEvent ()

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSString *biddingPrice;

@end

@implementation AnyThinkMentaRewardedVideoCustomEvent

- (NSString *)networkUnitId {
    return self.serverInfo[@"slotID"];
}

/// 广告策略服务加载成功
- (void)menta_didFinishLoadingRewardVideoADPolicy:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
}

/// 激励视频广告数据拉取成功
- (void)menta_rewardVideoAdDidLoad:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

/// 激励视频广告视频下载成功
- (void)menta_rewardVideoAdMaterialDidLoad:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
    self.isReady = YES;
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        if (request == nil) {
            return;
        }
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID 
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:self.biddingPrice
                                                     currencyType:ATBiddingCurrencyTypeCNY expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:rewardVideoAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackRewardedVideoAdLoaded:rewardVideoAd adExtra:nil];
    }
}

/// 激励视频加载失败
- (void)menta_rewardVideoAd:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
    NSLog(@"------> %s", __FUNCTION__);
    NSError *err = [NSError errorWithDomain:@"com.menta.nativeExpress"
                                       code:100
                                   userInfo:@{}];
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        if (request.bidCompletion) {
            request.bidCompletion(nil, err);
        }
        [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
    } else {
        [self trackRewardedVideoAdLoadFailed:err];
    }
}

/// 激励视频广告被点击了
- (void)menta_rewardVideoAdDidClick:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackRewardedVideoAdClick];
}

/// 激励视频广告关闭了
- (void)menta_rewardVideoAdDidClose:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd closeMode:(MentaRewardVideoAdCloseMode)mode {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted extra:@{kATADDelegateExtraDismissTypeKey:self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

/// 激励视频将要展现
- (void)menta_rewardVideoAdWillVisible:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
}

/// 激励视频广告曝光
- (void)menta_rewardVideoAdDidExpose:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

/// 激励视频广告播放达到激励条件回调
- (void)menta_rewardVideoAdDidRewardEffective:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
    if (self.rewardGranted == NO) {
        // frist rewarded
        [self trackRewardedVideoAdRewarded];
    }
}

/// 激励视频广告播放完成回调
- (void)menta_rewardVideoAdDidPlayFinish:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd {
    NSLog(@"------> %s", __FUNCTION__);
    self.closeType = ATAdCloseCountdown;
    [self trackRewardedVideoAdVideoEnd];
}

/// 激励视频广告 展现的广告信息 曝光之前会触发该回调
- (void)menta_rewardVideoAd:(MentaUnifiedRewardVideoAd *_Nonnull)rewardVideoAd bestTargetSourcePlatformInfo:(NSDictionary *_Nonnull)info {
    NSLog(@"------> %s", __FUNCTION__);
    self.biddingPrice = [NSString stringWithFormat:@"%.2f",[info[@"BEST_SOURCE_PRICE"] doubleValue] / 100.0];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
