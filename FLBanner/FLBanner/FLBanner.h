//
//  FLBanner.h
//  FLProgram
//
//  Created by FL on 15/10/23.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FLLBannerPageCtrollerPosition) {
    FLLBannerPageCtrollerLeft = 0,                  //在banner的左侧
    FLLBannerPageCtrollerCenter = 1,                //在banner的中间
    FLLBannerPageCtrollerRight = 2                  //在banner的右侧
};

typedef void (^FLBannerBlock) (NSInteger index);

@interface FLBanner : UIView
/**
 * 【使用须知】
 *  本轮播图图片加载，基于SDWebImage
 *  建议使用 initWithFrame:(CGRect)frame；方法初始化视图
 *  如果是init方法初始化视图必须调用- (void)layoutWidth:(CGFloat)width height:(CGFloat)height，否则轮播图显示异常
 */

/**
 * 设置布局（重点 : 否则无法正常显示效果）
 * width:当前视图宽度
 * height:轮播图高度
 */
- (void)layoutWidth:(CGFloat)width height:(CGFloat)height;

/**
 * 设置轮播图显示图片
 * array: 图片数组,image需单独取出来组合数组(支持本地图片名字字符串，网络图片字符串，以及UIImage格式)
 * block: 点击图片触发的回调
 */
- (void)refreshUI:(NSArray *)array action:(FLBannerBlock)block;

//设置是否隐藏pageControl（默认NO）
- (void)setPageCtlHidden:(BOOL)isHidden;
//设置是否重复滚动（默认YES）
- (void)setRepeatScroll:(BOOL)isRepeat;
//启动定时滑动模式 (默认3秒)
- (void)startTimer:(NSTimeInterval)timeInterval;
//停止定时器
- (void)stopTimer;

@end



@interface FLBannerCell : UICollectionViewCell

- (void)refreshUI:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
