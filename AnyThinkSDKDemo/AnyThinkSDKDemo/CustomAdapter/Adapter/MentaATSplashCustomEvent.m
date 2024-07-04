//
//  MentaATSplashCustomEvent.m
//  yxy_app
//
//  Created by 云马Mac on 2024/2/2.
//  Copyright © 2024 王云祥. All rights reserved.
//

#import "MentaATSplashCustomEvent.h"
#import "ATTMBiddingManager.h"
#import "ATTMBiddingRequest.h"

@implementation MentaATSplashCustomEvent

- (void)bidResultCall:(NSString *)ecpm splashAd:(id)ad withError:(NSError *)error{
    ATTMBiddingRequest *request = [[ATTMBiddingManager sharedInstance] getRequestItemWithUnitID:self.soltID];
    if (request.bidCompletion) {
        if (error == nil) {
            ATBidInfo *bidInfo =  [ATBidInfo bidInfoC2SWithPlacementID:request.placementID
                                                       unitGroupUnitID:request.unitGroup.unitID
                                                    adapterClassString:request.unitGroup.adapterClassString
                                                                 price:ecpm
                                                          currencyType:ATBiddingCurrencyTypeCNY
                                                    expirationInterval:request.unitGroup.networkTimeout
                                                          customObject:ad];
            request.bidCompletion(bidInfo, nil);
        }else {
            request.bidCompletion(nil, error);
        }
    }

}



/// 开屏广告数据拉取成功
- (void)menta_splashAdDidLoad:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    if (self.soltID != nil) {
        [self bidResultCall:self.biddingPrice splashAd:splashAd withError:nil];
    }else {
        self.isReady = true;
        [self trackSplashAdLoaded:splashAd];
    }
    NSLog(@"------> menta_splashAdDidLoad ");

}

/// 开屏加载失败
- (void)menta_splashAd:(MentaUnifiedSplashAd *_Nonnull)splashAd didFailWithError:(NSError * _Nullable)error description:(NSDictionary *_Nonnull)description {
    NSLog(@"Menta load 失败：%@",error);
    if (self.unitID != nil) {
        [self bidResultCall:nil splashAd:splashAd withError:error];
    }else {
        [self trackSplashAdLoadFailed:error];
    }
    NSLog(@"------> didFailWithError ");
}

/// 开屏广告被点击了
- (void)menta_splashAdDidClick:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    [self trackSplashAdClick];
    NSLog(@"------> menta_splashAdDidClick ");
}

/// 开屏广告关闭了
- (void)menta_splashAdDidClose:(MentaUnifiedSplashAd *_Nonnull)splashAd closeMode:(MentaSplashAdCloseMode)mode {
    [self trackSplashAdClosed:@{}];
    NSLog(@"------> menta_splashAdDidClose ");
}

/// 开屏广告曝光
- (void)menta_splashAdDidExpose:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    [self trackSplashAdShow];
    NSLog(@"------> menta_splashAdDidExpose ");

}


/// 广告策略服务加载成功
- (void)menta_didFinishLoadingADPolicy:(MentaUnifiedSplashAd *_Nonnull)splashAd {
    NSLog(@"------> menta_didFinishLoadingADPolicy ");
}

/// 开屏广告 展现的广告信息 曝光之后会触发该回调
- (void)menta_splashAd:(MentaUnifiedSplashAd *_Nonnull)splashAd bestTargetSourcePlatformInfo:(NSDictionary *_Nonnull)info {
   
    self.biddingPrice = [NSString stringWithFormat:@"%.2f",[info[@"BEST_SOURCE_PRICE"] integerValue]/100.0];
    NSLog(@"------> bestTargetSourcePlatformInfo %@",self.biddingPrice);
}

- (void)dealloc
{
    NSLog(@"MentaATSplashCustomEvent dealloc");
}

@end
