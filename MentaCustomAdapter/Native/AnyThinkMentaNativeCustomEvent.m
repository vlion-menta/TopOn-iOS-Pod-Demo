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
- (void)nativeExpressAdLoadedWith:(MentaUnifiedNativeExpressAd *)nativeExpressAd
               nativeExpressAdObj:(MentaUnifiedNativeExpressAdObject *)nativeExpressAdObj {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeExpressAdObj forKey:kATAdAssetsCustomObjectKey];
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
- (void)nativeAdLoadedWith:(MentaUnifiedNativeAd *)nativeAd
               nativeAdObj:(MentaNativeObject *)nativeObj {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray<NSDictionary*>* assets = [NSMutableArray<NSDictionary*> array];
        NSMutableDictionary *asset = [NSMutableDictionary dictionary];
        
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:self forKey:kATAdAssetsCustomEventKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj forKey:kATAdAssetsCustomObjectKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(0) forKey:kATNativeADAssetsIsExpressAdKey];
        
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj.dataObject.title forKey:kATNativeADAssetsMainTitleKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj.dataObject.desc forKey:kATNativeADAssetsMainTextKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj.dataObject.iconUrl forKey:kATNativeADAssetsIconURLKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj.dataObject.materialList.firstObject.materialUrl forKey:kATNativeADAssetsImageURLKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@"AdVlion" forKey:kATNativeADAssetsAdvertiserKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(nativeObj.dataObject.isVideo) forKey:kATNativeADAssetsContainsVideoFlag];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj.dataObject.adIcon forKey:kATNativeADAssetsLogoImageKey];
        [AnyThinkMentaNativeCustomEvent dic:asset setValue:nativeObj.dataObject.price forKey:kATNativeADAssetsAppPriceKey];
        if (nativeObj.dataObject.isVideo) {
            CGFloat videoAspect = nativeObj.dataObject.videoWidth / nativeObj.dataObject.videoHeight;
            [AnyThinkMentaNativeCustomEventInland dic:asset setValue:@(videoAspect) forKey:kATNativeADAssetsVideoAspectRatioKey];
            [AnyThinkMentaNativeCustomEventInland dic:asset setValue:@(nativeObj.dataObject.videoDuration) forKey:kATNativeADAssetsVideoDurationKey];
        } else {
            [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(nativeObj.dataObject.materialList.firstObject.materialWidth) forKey:kATNativeADAssetsMainImageWidthKey];
            [AnyThinkMentaNativeCustomEvent dic:asset setValue:@(nativeObj.dataObject.materialList.firstObject.materialHeight) forKey:kATNativeADAssetsMainImageHeightKey];
        }
        
        [assets addObject:asset];
        [self trackNativeAdLoaded:assets];
    });
}

#pragma mark - MentaUnifiedNativeExpressAdDelegate

/// 广告策略服务加载成功
- (void)menta_didFinishLoadingADPolicy:(MentaUnifiedNativeExpressAd *_Nonnull)nativeExpressAd {
    NSLog(@"------> %s", __FUNCTION__);
}

/**
 广告数据回调
 @param unifiedNativeAdDataObjects 广告数据数组
 */
- (void)menta_nativeExpressAdLoaded:(NSArray<MentaUnifiedNativeExpressAdObject *> * _Nullable)unifiedNativeAdDataObjects nativeExpressAd:(MentaUnifiedNativeExpressAd *_Nonnull)nativeExpressAd {
    NSLog(@"------> %s", __FUNCTION__);
}


/**
信息流广告加载失败
@param nativeExpressAd MentaUnifiedNativeExpressAd 实例,
@param error 错误
*/
- (void)menta_nativeExpressAd:(MentaUnifiedNativeExpressAd *_Nonnull)nativeExpressAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
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

/**
 信息流渲染成功
 @param nativeExpressAd MentaUnifiedNativeExpressAd 实例,
 */
- (void)menta_nativeExpressAdViewRenderSuccess:(MentaUnifiedNativeExpressAd *_Nonnull)nativeExpressAd 
                         nativeExpressAdObject:(MentaUnifiedNativeExpressAdObject *_Nonnull)nativeExpressAdObj {
    NSLog(@"------> %s", __FUNCTION__);
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        request.nativeAds = @[nativeExpressAdObj];
        NSNumber *price = @(nativeExpressAdObj.price.doubleValue / 100.0);
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:price.stringValue
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:nativeExpressAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        self.isC2SBiding = NO;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
    } else {
        [self nativeExpressAdLoadedWith:nativeExpressAd nativeExpressAdObj:nativeExpressAdObj];
    }
}

/**
 信息流渲染失败
 @param nativeExpressAd MentaUnifiedNativeExpressAd 实例,
 */
- (void)nativeExpressAdViewRenderFail:(MentaUnifiedNativeExpressAd *_Nonnull)nativeExpressAd nativeExpressAdObject:(MentaUnifiedNativeExpressAdObject *_Nonnull)nativeExpressAdObj {
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

/**
 广告曝光回调
 @param nativeExpressAd MentaUnifiedNativeExpressAd 实例,
 */
- (void)menta_nativeExpressAdViewWillExpose:(MentaUnifiedNativeExpressAd *_Nullable)nativeExpressAd nativeExpressAdObject:(MentaUnifiedNativeExpressAdObject *_Nonnull)nativeExpressAdObj {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdImpression];
}


/**
 广告点击回调,
 @param nativeExpressAd MentaUnifiedNativeExpressAd 实例,
 */
- (void)menta_nativeExpressAdViewDidClick:(MentaUnifiedNativeExpressAd *_Nullable)nativeExpressAd nativeExpressAdObject:(MentaUnifiedNativeExpressAdObject *_Nonnull)nativeExpressAdObj {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdClick];
}

/**
 广告点击关闭回调 UI的移除和数据的解绑 需要在该回调中进行
 @param nativeExpressAd MentaUnifiedNativeExpressAd 实例,
 */
- (void)menta_nativeExpressAdDidClose:(MentaUnifiedNativeExpressAd *_Nonnull)nativeExpressAd nativeExpressAdObject:(MentaUnifiedNativeExpressAdObject *_Nonnull)nativeExpressAdObj {
    NSLog(@"------> %s", __FUNCTION__);
    [self trackNativeAdClosed];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
}

#pragma mark - MentaUnifiedNativeAdDelegate

/**
 广告数据回调
 @param unifiedNativeAdDataObjects 广告数据数组
 */
- (void)menta_nativeAdLoaded:(NSArray<MentaNativeObject *> * _Nullable)unifiedNativeAdDataObjects nativeAd:(MentaUnifiedNativeAd *_Nullable)nativeAd {
    NSLog(@"------> %s", __FUNCTION__);
    
    if (self.isC2SBiding) {
        AnyThinkMentaBiddingRequest *request = [[AnyThinkMentaBiddingManager sharedInstance] getRequestItemWithUnitID:self.networkAdvertisingID];
        request.nativeAds = unifiedNativeAdDataObjects;
        NSNumber *price = @(unifiedNativeAdDataObjects.firstObject.dataObject.price.doubleValue / 100.0);
        ATBidInfo *bidInfo = [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                  unitGroupUnitID:request.unitGroup.unitID
                                               adapterClassString:request.unitGroup.adapterClassString
                                                            price:price.stringValue
                                                     currencyType:ATBiddingCurrencyTypeCNY
                                               expirationInterval:request.unitGroup.bidTokenTime
                                                     customObject:nativeAd];
        bidInfo.networkFirmID = request.unitGroup.networkFirmID;
        self.isC2SBiding = NO;
        
        if (request.bidCompletion) {
            request.bidCompletion(bidInfo, nil);
        }
    } else {
        [self nativeAdLoadedWith:nativeAd nativeAdObj:unifiedNativeAdDataObjects.firstObject];
    }
}

/// 信息流自渲染加载失败
- (void)menta_nativeAd:(MentaUnifiedNativeAd *_Nonnull)nativeAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
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

/**
 广告曝光回调,
 @param nativeAd MentaUnifiedNativeAd 实例,
 @param adView 广告View
 */
- (void)menta_nativeAdViewWillExpose:(MentaUnifiedNativeAd *_Nullable)nativeAd adView:(UIView<MentaNativeAdViewProtocol> *_Nonnull)adView {
    NSLog(@"------> %s", __FUNCTION__);
    
    [self trackNativeAdImpression];
}


/**
 广告点击回调,
 @param nativeAd MentaUnifiedNativeAd 实例,
 */
- (void)menta_nativeAdViewDidClick:(MentaUnifiedNativeAd *_Nullable)nativeAd adView:(UIView<MentaNativeAdViewProtocol> *_Nullable)adView {
    NSLog(@"------> %s", __FUNCTION__);
    
    [self trackNativeAdClick];
}

/**
 广告点击关闭回调 UI的移除和数据的解绑 需要在该回调中进行
 @param nativeAd MentaUnifiedNativeAd 实例,
 */
- (void)menta_nativeAdDidClose:(MentaUnifiedNativeAd *_Nonnull)nativeAd adView:(UIView<MentaNativeAdViewProtocol> *_Nullable)adView {
    NSLog(@"------> %s", __FUNCTION__);
    
    [self trackNativeAdClosed];
    [[AnyThinkMentaBiddingManager sharedInstance] removeRequestItmeWithUnitID:self.networkAdvertisingID];
}

/**
 广告详情页面即将展示回调, 当广告位落地页广告时会触发

 @param nativeAd MentaUnifiedNativeAd 实例,
 */
- (void)menta_nativeAdDetailViewWillPresentScreen:(MentaUnifiedNativeAd *_Nullable)nativeAd adView:(UIView<MentaNativeAdViewProtocol> *_Nonnull)adView {
    NSLog(@"------> %s", __FUNCTION__);
}

/**
 广告详情页关闭回调,即落地页关闭回调, 当关闭弹出的落地页时 触发

 @param nativeAd MentaUnifiedNativeAd 实例,
 */
- (void)menta_nativeAdDetailViewClosed:(MentaUnifiedNativeAd *_Nullable)nativeAd adView:(UIView<MentaNativeAdViewProtocol> *_Nonnull)adView {
    NSLog(@"------> %s", __FUNCTION__);
}

- (void)dealloc
{
    NSLog(@"------> %s", __FUNCTION__);
}

@end
