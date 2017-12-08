//
//  IndicatorView.h
//  IndicatorView
//
//  Created by LOLITA on 17/7/4.
//  Copyright © 2017年 LOLITA. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger,IndicatorType) {
    IndicatorTypeBounceSpot1,           // 圆环圆点
    IndicatorTypeBounceSpot2,           // 线型圆点
    IndicatorTypeBounceSpot3,           // 三角型圆点
    IndicatorTypeCyclingLine,           // 虚线圆环
    IndicatorTypeCyclingCycle1,         // 单线圆环
    IndicatorTypeCyclingCycle2,         // 多线圆环
    IndicatorTypeMusic1,                // music类型1
    IndicatorTypeMusic2,                // music类型2
    IndicatorTypeStock                  // 股票折线
};

@interface IndicatorView : UIView

@property (strong ,nonatomic) UIColor *loadingTintColor;

/**
 是否在加载中
 */
@property BOOL isAnimating;

-(instancetype)initWithType:(IndicatorType)type;
-(instancetype)initWithType:(IndicatorType)type tintColor:(UIColor *)color;
-(instancetype)initWithType:(IndicatorType)type tintColor:(UIColor *)color size:(CGSize)size;


/**
 开始
 */
-(void)startAnimating;

/**
 停止
 */
-(void)stopAnimating;




@end




























#pragma mark - *********************************************** 协议 ***********************************************






@protocol IndicatorAnimationProtocol <NSObject>

@optional

-(void)configAnimationLayer:(CALayer*)layer withTintColor:(UIColor*)color size:(CGSize)size;

-(void)removeAnimation;

@end







#pragma mark - *********************************************** 动画module ***********************************************




@interface IndicatorAnimation : NSObject <IndicatorAnimationProtocol,CAAnimationDelegate>

@property CALayer *itemLayer;

@property (strong ,nonatomic) CABasicAnimation *animation;

@end



/**
 圆环圆点
 */
@interface IndicatorBounceSpot1Animation : IndicatorAnimation

@end



/**
 线型圆点
 */
@interface IndicatorBounceSpot2Animation : IndicatorAnimation

@end



/**
 三角型圆点
 */
@interface IndicatorBounceSpot3Animation : IndicatorAnimation

@property (strong ,nonatomic) CAKeyframeAnimation *animationKey;

@end



/**
 虚线圆环
 */
@interface IndicatorCyclingLineAnimation : IndicatorAnimation

@end



/**
 单线圆环
 */
@interface IndicatorCyclingCycle1Animation : IndicatorAnimation

@end



/**
 多线圆环
 */
@interface IndicatorCyclingCycle2Animation : IndicatorAnimation



@end



/**
 音乐类型1
 */
@interface IndicatorMusic1Animation : IndicatorAnimation

@end



/**
 音乐类型2
 */
@interface IndicatorMusic2Animation : IndicatorAnimation

@end



/**
 折线
 */
@interface IndicatorStockAnimation : IndicatorAnimation

@end










