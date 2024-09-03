//
//  AnyThinkMentaNativeExpressCustomEvent.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import "AnyThinkMentaNativeCustomEvent.h"
#import "AnyThinkMentaBiddingManager.h"
#import "AnyThinkMentaBiddingRequest.h"

@implementation AnyThinkMentaNativeCustomEvent

+ (void)dic:(NSMutableDictionary *)dictionary setValue:(id)value forKey:(NSString *)key {
    if (!dictionary || !value || !key) {
        return;
    }
    [dictionary setObject:value forKey:key];
}

// 模版渲染
- (void)nativeExpressAdLoadedWith:(MentaMediationNativeExpress *)nativeExpresAd
              nativeExpressAdView:(UIView *)nativeExpressAdView {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeExpresAd forKey:@"kMentaNativeExpressObj"];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeExpressAdView forKey:kATAdAssetsCustomObjectKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(1) forKey:kATNativeADAssetsIsExpressAdKey];
        
        // express
        CGSize adSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 20.0, 300.0f);
        if ([self.serverInfo[kATExtraInfoNativeAdSizeKey] respondsToSelector:@selector(CGSizeValue)]) {
            adSize = [self.serverInfo[kATExtraInfoNativeAdSizeKey] CGSizeValue];
        }
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:[NSString stringWithFormat:@"%lf",adSize.width] forKey:kATNativeADAssetsNativeExpressAdViewWidthKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:[NSString stringWithFormat:@"%lf",adSize.height] forKey:kATNativeADAssetsNativeExpressAdViewHeightKey];
        [assets addObject:asset];
        
        [self trackNativeAdLoaded:assets];
    });
}

// 自渲染
- (void)nativeSelfRenderAdLoadedWith:(MentaMediationNativeSelfRender *)nativeSelfRenderAd
             nativeSelfRenderAdModel:(MentaMediationNativeSelfRenderModel *)nativeSelfRenderAdModel {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAd forKey:@"kMentaNativeSelfRenderObj"];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel forKey:kATAdAssetsCustomObjectKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(0) forKey:kATNativeADAssetsIsExpressAdKey];
        
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel.title forKey:kATNativeADAssetsMainTitleKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel.des forKey:kATNativeADAssetsMainTextKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel.iconURL forKey:kATNativeADAssetsIconURLKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel.materialURL forKey:kATNativeADAssetsImageURLKey];
//        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@"AdVlion" forKey:kATNativeADAssetsAdvertiserKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(nativeSelfRenderAdModel.isVideo) forKey:kATNativeADAssetsContainsVideoFlag];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel.adLogo.logoImg forKey:kATNativeADAssetsLogoImageKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeSelfRenderAdModel.eCPM forKey:kATNativeADAssetsAppPriceKey];
        if (nativeSelfRenderAdModel.isVideo) {
            CGFloat videoAspect = nativeSelfRenderAdModel.videoCoverWidth / nativeSelfRenderAdModel.videoCoverHeight;
            [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(videoAspect) forKey:kATNativeADAssetsVideoAspectRatioKey];
        } else {
            [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(nativeSelfRenderAdModel.materialWidth) forKey:kATNativeADAssetsMainImageWidthKey];
            [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(nativeSelfRenderAdModel.materialHeight) forKey:kATNativeADAssetsMainImageHeightKey];
        }
        
        [assets addObject:asset];
        [self trackNativeAdLoaded:assets];
    });
}

#pragma mark - MentaMediationNativeExpressDelegate

// 广告素材加载成功
- (void)menta_nativeExpressAdDidLoad:(MentaMediationNativeExpress *)nativeExpress {
    NSLog(@"------> %s", __FUNCTION__);
}

// 广告素材加载失败
- (void)menta_nativeExpressAdLoadFailedWithError:(NSError *)error nativeExpress:(MentaMediationNativeExpress *)nativeExpress {
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
        [self trackNativeAdLoadFailed:err];
    }
}

// 广告素材渲染成功
// 此时可以获取 ecpm
- (void)menta_nativeExpressAdRenderSuccess:(MentaMediationNativeExpress *)nativeExpress nativeExpressView:(UIView *)nativeExpressView {
    NSLog(@"------> %s", __FUNCTION__);
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        request.nativeAds = @[nativeExpressView];
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:nativeExpress.eCPM
                                                     currencyType:ATBiddingCurrencyTypeUS
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:nativeExpress];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        self.isC2SBiding = NO;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
    } else {
        [self nativeExpressAdLoadedWith:nativeExpress nativeExpressAdView:nativeExpressView];
    }
}

// 广告素材渲染失败
- (void)menta_nativeExpressAdRenderFailureWithError:(NSError *)error nativeExpress:(MentaMediationNativeExpress *)nativeExpress {
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
        [self trackNativeAdLoadFailed:err];
    }
}

// 广告曝光
- (void)menta_nativeExpressAdExposed:(MentaMediationNativeExpress *)nativeExpress {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdImpression];
}

// 广告点击
- (void)menta_nativeExpressrAdClicked:(MentaMediationNativeExpress *)nativeExpress {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdClick];
}

// 广告关闭
-(void)menta_nativeExpressAdClosed:(MentaMediationNativeExpress *)nativeExpress {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdClosed];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
}

#pragma mark - MentaNativeSelfRenderDelegate

- (void)menta_nativeSelfRenderLoadSuccess:(NSArray<MentaMediationNativeSelfRenderModel *> *)nativeSelfRenderAds
                         nativeSelfRender:(MentaMediationNativeSelfRender *)nativeSelfRender {
    NSLog(@"------> %s", __FUNCTION__);
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        request.nativeAds = nativeSelfRenderAds;
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:nativeSelfRenderAds.firstObject.eCPM
                                                     currencyType:ATBiddingCurrencyTypeUS
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:nativeSelfRender];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        self.isC2SBiding = NO;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
    } else {
        [self nativeSelfRenderAdLoadedWith:nativeSelfRender nativeSelfRenderAdModel:nativeSelfRenderAds.firstObject];
    }
}

- (void)menta_nativeSelfRenderLoadFailure:(NSError *)error
                         nativeSelfRender:(MentaMediationNativeSelfRender *)nativeSelfRender {
    NSLog(@"------> %s", __FUNCTION__);
    
    NSError *err = [NSError errorWithDomain:@"com.menta.native"
                                       code:100
                                   userInfo:@{}];
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        if (request.bidCompletion) {
            request.bidCompletion(nil, err);
        }
        [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
    } else {
        [self trackNativeAdLoadFailed:err];
    }
}

- (void)menta_nativeSelfRenderViewExposed {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdImpression];
}

- (void)menta_nativeSelfRenderViewClicked {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdClick];
}

- (void)menta_nativeSelfRenderViewClosed {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdClosed];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}

@end
