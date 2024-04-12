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

-(void) renderOffer:(ATNativeADCache *)offer {
    [super renderOffer:offer];
    
    UIViewController *rootVC = self.configuration.rootViewController;
    if (rootVC == nil) {
        rootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    BOOL isExpress = [offer.assets[kATNativeADAssetsIsExpressAdKey] boolValue];
    if (isExpress) {
        MentaUnifiedNativeExpressAdObject *expressObj = offer.assets[kATAdAssetsCustomObjectKey];
        expressObj.expressView.backgroundColor = self.ADView.backgroundColor;
        CGFloat height = self.ADView.frame.size.height;
        expressObj.expressView.frame = CGRectMake(0, 0, self.ADView.frame.size.width, height);
        
        [self.ADView insertSubview:(UIView *)expressObj.expressView atIndex:0];
        
    } else {
        
    }
}

- (ATNativeAdRenderType)getCurrentNativeAdRenderType {
    ATNativeADCache *cache = ((ATNativeADCache*)(((id<ATNativeADView>)self.ADView).nativeAd));
    return ATNativeAdRenderExpress;
}

- (void)dealloc {
    NSLog(@"------> %s", __FUNCTION__);
}

@end
