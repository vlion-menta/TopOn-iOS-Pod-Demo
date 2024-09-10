//
//  AnyThinkMentaRewardedVideoAdapter.h
//  AnyThinkMentaCustomAdapter
//
//  Created by jdy on 2024/4/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AnyThinkMentaRewardedVideoAdapter : NSObject

@property (nonatomic,copy) void (^metaDataDidLoadedBlock)(void);

@end

NS_ASSUME_NONNULL_END
