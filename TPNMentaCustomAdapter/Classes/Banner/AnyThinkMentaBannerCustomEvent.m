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

// 广告素材加载成功
- (void)menta_bannerAdDidLoad:(MentaMediationBanner *)banner {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告素材加载失败
- (void)menta_bannerAdLoadFailedWithError:(NSError *)error banner:(MentaMediationBanner *)banner {
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

// 广告素材渲染成功
// 此时可以获取 ecpm
- (void)menta_bannerAdRenderSuccess:(MentaMediationBanner *)banner bannerAdView:(UIView *)bannerAdView {
    NSLog(@"------> %s", __FUNCTION__);
    double ecpm = banner.eCPM.doubleValue;
    if (ecpm > 0) {
        self.biddingPrice = [NSString stringWithFormat:@"%f", ecpm / 100];
    }
    
    if (bannerAdView) {
        bannerAdView.frame = CGRectMake(0, 0, self.width, self.height);
    }
    
    if (self.isC2SBiding && [banner isAdReady]) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.UUID];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:self.biddingPrice
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:banner];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
        self.isC2SBiding = NO;
    } else if ([banner isAdReady]) {
        [self trackBannerAdLoaded:banner adExtra:nil];
    }
}

// 广告素材渲染失败
- (void)menta_bannerAdRenderFailureWithError:(NSError *)error banner:(MentaMediationBanner *)banner {
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

// 广告曝光
- (void)menta_bannerAdExposed:(MentaMediationBanner *)banner {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackBannerAdImpression];
}

// 广告点击
- (void)menta_bannerAdClicked:(MentaMediationBanner *)banner {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackBannerAdClick];
}

// 广告关闭
-(void)menta_bannerAdClosed:(MentaMediationBanner *)banner {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackBannerAdClosed];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.UUID];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}


@end
