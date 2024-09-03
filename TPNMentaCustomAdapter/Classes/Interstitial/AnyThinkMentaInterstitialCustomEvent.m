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

@end

@implementation AnyThinkMentaInterstitialCustomEvent

// 广告素材加载成功
- (void)menta_interstitialDidLoad:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告素材加载失败
- (void)menta_interstitialLoadFailedWithError:(NSError *)error interstitial:(MentaMediationInterstitial *)interstitial {
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

// 广告素材渲染成功
// 此时可以获取 ecpm
- (void)menta_interstitialRenderSuccess:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
    self.isReady = YES;
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:interstitial.eCPM
                                                     currencyType:ATBiddingCurrencyTypeUS
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:interstitial];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else {
        [self trackInterstitialAdLoaded:interstitial adExtra:nil];
    }
}

// 广告素材渲染失败
- (void)menta_interstitialRenderFailureWithError:(NSError *)error interstitial:(MentaMediationInterstitial *)interstitial {
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

// 广告即将展示
- (void)menta_interstitialWillPresent:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告展示失败
- (void)menta_interstitialShowFailWithError:(NSError *)error interstitial:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告曝光
- (void)menta_interstitialExposed:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackInterstitialAdShow];
}

// 广告点击
- (void)menta_interstitialClicked:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
    self.closeType = ATAdCloseClickcontent;
    [self trackInterstitialAdClick];
}

// 视频播放完成
- (void)menta_interstitialPlayCompleted:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告关闭
-(void)menta_interstitialClosed:(MentaMediationInterstitial *)interstitial {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackInterstitialAdClose:@{kATADDelegateExtraDismissTypeKey: self.closeType != 0 ? @(self.closeType) : @(ATAdCloseUnknow)}];
}

- (void)dealloc {
    NSLog(@"------> %s", __FUNCTION__);
}

@end
