//
//  AnyThinkMentaNativeRender.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import "AnyThinkMentaNativeRender.h"
#import <AnyThinkSDK/AnyThinkSDK.h>
#import <MentaMediationGlobal/MentaMediationGlobal-umbrella.h>

@protocol ATNativeADView<NSObject>
@property (nonatomic, readonly) ATNativeADCache *nativeAd;
@end

@interface AnyThinkMentaNativeRender ()

@property (nonatomic, strong) AnyThinkMentaNativeCustomEvent *customEvent;
@property (nonatomic, assign) CGFloat expressAdHeight;
@property (nonatomic, strong) UIView *canvasView;
@property (nonatomic, assign) BOOL isAddKVOframe;

@end

@implementation AnyThinkMentaNativeRender

- (void)bindCustomEvent {
    AnyThinkMentaNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kATAdAssetsCustomEventKey];
    customEvent.adView = self.ADView;
    self.ADView.customEvent = customEvent;
}

- (UIView *)getNetWorkMediaView {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BOOL isExpress = [cache.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (!isExpress) {
        MentaMediationNativeSelfRenderModel *selfRenderModel = cache.assets[kATAdAssetsCustomObjectKey];
//        MentaNativeObject *nativeAd = cache.assets[kATAdAssetsCustomObjectKey];
        if (selfRenderModel.isVideo) {
            return selfRenderModel.selfRenderView.mediaView;
        }
    }
    return nil;
}

-(void)renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    
    BOOL isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (isExpress) {
        AnyThinkMentaNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kATAdAssetsCustomEventKey];
        MentaMediationNativeExpress *nativeExpress = (MentaMediationNativeExpress *)offer.assets[@"kMentaNativeExpressObj"];
        nativeExpress.delegate = customEvent;
        
        UIView *nativeExpressView = offer.assets[kATAdAssetsCustomObjectKey];
        nativeExpressView.backgroundColor = self.ADView.backgroundColor;
        CGFloat height = self.ADView.frame.size.height;
        nativeExpressView.frame = CGRectMake(0, 0, self.ADView.frame.size.width, height);
        
        [self.ADView insertSubview:nativeExpressView atIndex:0];
        
    } else {
        AnyThinkMentaNativeCustomEvent *customEvent = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd)).assets[kATAdAssetsCustomEventKey];
        MentaMediationNativeSelfRender *nativeSelfRender = (MentaMediationNativeSelfRender *)offer.assets[@"kMentaNativeSelfRenderObj"];
        nativeSelfRender.delegate = customEvent;
        
        MentaMediationNativeSelfRenderModel *selfRenderModel = offer.assets[kATAdAssetsCustomObjectKey];
        selfRenderModel.selfRenderView.backgroundColor = [UIColor clearColor];
        [self.ADView setNeedsLayout];
        [self.ADView layoutIfNeeded];
        selfRenderModel.selfRenderView.frame = self.ADView.bounds;
        [selfRenderModel.selfRenderView inMediation:YES];
        [selfRenderModel.selfRenderView menta_registerClickableViews:[self.ADView clickableViews] closeableViews:@[]];
        [self.ADView insertSubview:selfRenderModel.selfRenderView atIndex:0];
    }
}

- (BOOL)isVideoContents {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BOOL isExpress = [cache.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (!isExpress) {
        MentaMediationNativeSelfRenderModel *selfRenderModel = cache.assets[kATAdAssetsCustomObjectKey];
        if (selfRenderModel.isVideo) {
            return YES;
        }
    }
    
    return NO;
}

- (ATNativeAdRenderType)getCurrentNativeAdRenderType {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BOOL isExpress = [cache.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (isExpress) {
        return ATNativeAdRenderExpress;
    } else {
        return ATNativeAdRenderSelfRender;
    }
}

- (void)dealloc {
    NSLog(@"------> %s", __FUNCTION__);
}

@end
