//
//  AnyThinkMentaNativeRender.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/12.
//

#import <AnyThinkNative/AnyThinkNative.h>
#import "AnyThinkMentaNativeCustomEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaNativeRender : ATNativeRenderer

@property(nonatomic, strong, readonly) AnyThinkMentaNativeCustomEvent *customEvent;

@end

NS_ASSUME_NONNULL_END
