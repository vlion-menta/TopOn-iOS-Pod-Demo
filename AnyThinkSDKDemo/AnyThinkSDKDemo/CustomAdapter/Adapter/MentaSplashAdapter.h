//
//  MentaSplashAdapter.h
//  yxy_app
//
//  Created by 云马Mac on 2024/2/2.
//  Copyright © 2024 王云祥. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSplash/AnyThinkSplash.h>
#import "MentaATSplashCustomEvent.h"
#import <MentaUnifiedSDK/MentaUnifiedSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface MentaSplashAdapter : NSObject

@property(nonatomic, readonly) MentaATSplashCustomEvent *customEvent;
@property(nonatomic, strong) MentaUnifiedSplashAd *splash;

@end

NS_ASSUME_NONNULL_END
