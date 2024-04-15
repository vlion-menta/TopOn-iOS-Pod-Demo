//
//  AnyThinkMentaNativeRender.m
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import "AnyThinkMentaNativeRender.h"
#import <AnyThinkSDK/ATAdManagement.h>
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>

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
        MentaNativeObject *nativeAd = cache.assets[kATAdAssetsCustomObjectKey];
        if (nativeAd.dataObject.isVideo) {
            return nativeAd.nativeAdView.mediaView;
        }
    }
    return nil;
}

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    
    BOOL isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (isExpress) {
        MentaUnifiedNativeExpressAdObject *expressObj = offer.assets[kATAdAssetsCustomObjectKey];
        expressObj.expressView.backgroundColor = self.ADView.backgroundColor;
        CGFloat height = self.ADView.frame.size.height;
        expressObj.expressView.frame = CGRectMake(0, 0, self.ADView.frame.size.width, height);
        
        [self.ADView insertSubview:(UIView *)expressObj.expressView atIndex:0];
        
    } else {
        MentaNativeObject *nativeAd = offer.assets[kATAdAssetsCustomObjectKey];
        nativeAd.nativeAdView.backgroundColor = self.ADView.backgroundColor;
        [self.ADView setNeedsLayout];
        [self.ADView layoutIfNeeded];
        nativeAd.nativeAdView.frame = self.ADView.bounds;
        [nativeAd registerClickableViews:[self.ADView clickableViews] closeableViews:@[]];
        [self.ADView insertSubview:(UIView *)nativeAd.nativeAdView atIndex:0];
    }
}

- (BOOL)isVideoContents {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    BOOL isExpress = [cache.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (!isExpress) {
        MentaNativeObject *nativeAd = cache.assets[kATAdAssetsCustomObjectKey];
        if (nativeAd.dataObject.isVideo) {
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
