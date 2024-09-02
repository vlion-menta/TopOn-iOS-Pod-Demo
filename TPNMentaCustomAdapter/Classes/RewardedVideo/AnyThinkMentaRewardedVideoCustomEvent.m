//
//  AnyThinkMentaRewardedVideoCustomEvent.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import "AnyThinkMentaRewardedVideoCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"

@interface AnyThinkMentaRewardedVideoCustomEvent ()

@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, strong) NSString *biddingPrice;

@end

@implementation AnyThinkMentaRewardedVideoCustomEvent

// 广告素材加载成功
- (void)menta_rewardVideoDidLoad:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    if (self.customEventMetaDataDidLoadedBlock != nil) { self.customEventMetaDataDidLoadedBlock();}
}

// 广告素材加载失败
- (void)menta_rewardVideoLoadFailedWithError:(NSError *)error rewardVideo:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s, %@", __FUNCTION__, error);
    NSError *err = [NSError errorWithDomain:@"com.menta.rewarded"
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

// 广告素材渲染成功
// 此时可以获取 ecpm
- (void)menta_rewardVideoRenderSuccess:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    self.isReady = YES;
    double ecpm = rewardVideo.eCPM.doubleValue;
    if (ecpm > 0) {
        self.biddingPrice = [NSString stringWithFormat:@"%f", ecpm / 100];
    }
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
                                                     customObject:rewardVideo];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackRewardedVideoAdLoaded:rewardVideo adExtra:nil];
    }
}

// 广告素材渲染失败
- (void)menta_rewardVideoRenderFailureWithError:(NSError *)error rewardVideo:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    NSError *err = [NSError errorWithDomain:@"com.menta.rewarded"
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

// 激励视频广告即将展示
- (void)menta_rewardVideoWillPresent:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
}

// 激励视频广告展示失败
- (void)menta_rewardVideoShowFailWithError:(NSError *)error rewardVideo:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
}

// 激励视频广告曝光
- (void)menta_rewardVideoExposed:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackRewardedVideoAdShow];
    [self trackRewardedVideoAdVideoStart];
}

// 激励视频广告点击
- (void)menta_rewardVideoClicked:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackRewardedVideoAdClick];
}

// 激励视频广告跳过
- (void)menta_rewardVideoSkiped:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
}

// 激励视频达到奖励节点
- (void)menta_rewardVideoDidEarnReward:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    if (self.rewardGranted == NO) {
        // frist rewarded
        [self trackRewardedVideoAdRewarded];
    }
}

// 激励视频播放完成
- (void)menta_rewardVideoPlayCompleted:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    self.closeType = ATAdCloseCountdown;
    [self trackRewardedVideoAdVideoEnd];
}

// 激励视频广告关闭
-(void)menta_rewardVideoClosed:(MentaMediationRewardVideo *)rewardVideo {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackRewardedVideoAdCloseRewarded:self.rewardGranted extra:@{kATADDelegateExtraDismissTypeKey:self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
}

- (NSString *)networkUnitId {
    return self.serverInfo[@"slotID"];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
