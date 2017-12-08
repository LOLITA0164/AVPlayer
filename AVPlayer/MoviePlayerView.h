//
//  MoviePlayerView.h
//  AVPlayer
//
//  Created by LOLITA on 2017/12/7.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+CWNView.h"
#import "IndicatorView.h"

@protocol MoviePlayerViewDelegate;

@interface MoviePlayerView : UIView

/**
 视频地址
 */
@property (copy ,nonatomic) NSString *urlString;

/**
 视频标题
 */
@property (copy ,nonatomic) NSString *movieTitle;

/**
 代理
 */
@property (nonatomic,weak) id <MoviePlayerViewDelegate> delegate;

/**
 是否自动播放
 */
@property (assign ,nonatomic) BOOL isAutoPlay;

/**
 是否需要全屏按钮
 */
@property (assign ,nonatomic) BOOL needFullScreenBtn;

/**
 指示器样式
 */
@property (assign ,nonatomic) IndicatorType indicatorType;

/**
 请求头部 实例：_player.referer = @"Referer:http://zhibo.zfxfu.com";
 */
@property (copy ,nonatomic) NSString * referer;


/**
 从头播放视频
 */
-(void)play;

/**
 停止
 */
-(void)stop;

/**
 暂停
 */
-(void)pause;

/**
 恢复
 */
-(void)resume;



@end



@protocol MoviePlayerViewDelegate <NSObject>

@optional
-(void)moviePlayerViewGoBackEvent:(MoviePlayerView*)playerView;    // 返回事件

@end






