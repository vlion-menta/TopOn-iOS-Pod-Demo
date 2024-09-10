//
//  AnyThinkMentaNativeRender.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import "AnyThinkMentaNativeCustomEventInland.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaNativeRenderInland : ATNativeRenderer

@property(nonatomic, strong, readonly) AnyThinkMentaNativeCustomEventInland *customEvent;

@end

NS_ASSUME_NONNULL_END
