//
//  AnyThinkMentaBiddingRequest.h
//  AnyThinkMentaSplashAdapter
//
//  Created by jdy on 2024/4/11.
//

#import <Foundation/Foundation.h>
#import <AnyThinkSDK/AnyThinkSDK.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MentaAdFormat) {
    MentaAdFormatSplash = 0,
    MentaAdFormatNativeExpress,
};

@interface AnyThinkMentaBiddingRequest : NSObject

@property (nonatomic, strong) id customObject;
@property (nonatomic, strong) ATUnitGroupModel *unitGroup;
@property (nonatomic, strong) ATAdCustomEvent *customEvent;
@property (nonatomic, copy) NSString *unitID;
@property (nonatomic, copy) NSString *placementID;
@property (nonatomic, copy) NSDictionary *extraInfo;
@property (nonatomic, copy) void(^bidCompletion)(ATBidInfo * _Nullable bidInfo, NSError * _Nullable error);
@property (nonatomic, assign) MentaAdFormat adType;
@property (nonatomic, strong) NSArray *nativeAds;

@end

NS_ASSUME_NONNULL_END
