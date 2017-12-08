//
//  MoviePlayerView.m
//  AVPlayer
//
//  Created by LOLITA on 2017/12/7.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#import "MoviePlayerView.h"
#import <PLPlayerKit/PLPlayerKit.h>
#import "RotationScreen.h"
#import "UIView+CWNView.h"

#define kTimerDuration 3
#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;
#define HexColor(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16)) / 255.0 green:((float)((hexValue & 0xFF00) >> 8)) / 255.0 blue:((float)(hexValue & 0xFF)) / 255.0 alpha:1.0]
#define KColorTheme HexColor(0x4083ff)

@interface MoviePlayerView ()<PLPlayerDelegate>
@property (strong ,nonatomic) PLPlayerOption *option;
@property (nonatomic, strong) PLPlayer  *player;
@property (strong ,nonatomic) IndicatorView *loading;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;


- (IBAction)goBackBtn:(UIButton *)sender;                               // 返回按钮
@property (weak, nonatomic) IBOutlet UILabel *titlelabel;               // 标题

@property (weak, nonatomic) IBOutlet UILabel *beginLabel;               // 起始时间
@property (weak, nonatomic) IBOutlet UIButton *playOrStopBtn;           // 播放或暂停按钮
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;          // 进度
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;      // 进度
@property (weak, nonatomic) IBOutlet UILabel *endLabel;                 // 结束时间
@property (weak, nonatomic) IBOutlet UIButton *fullscreenBtn;           // 全屏按钮

@property (strong ,nonatomic) NSTimer *playTimer;               // 播放定时器，取播放进度
@property (strong ,nonatomic) NSTimer *toolTimer;               // 工具栏显示定时器
@property (assign ,nonatomic) BOOL isSliding;                   // 是否正在滑动
@property (assign ,nonatomic) BOOL isShowTool;                  // 是否显示工具

@end

@implementation MoviePlayerView

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.bottomView insertSubview:self.progressView belowSubview:self.progressSlider];
    [self.progressSlider setThumbImage:[UIImage imageNamed:@"sliderTracing"] forState:UIControlStateNormal];
    [self.progressSlider addTarget:self action:@selector(onSliderTouchedDown:) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(onSliderTouchedUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    
    // 按钮事件
    [self.playOrStopBtn addTarget:self action:@selector(playOrStopBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.fullscreenBtn addTarget:self action:@selector(fullscreenBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 监听屏幕旋转
    //设备旋转通知
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleDeviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil
     ];
    
    
    // 收起控制台
    self.toolTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(hideTool) userInfo:nil repeats:NO];
    
    // 一些默认设置
    self.needFullScreenBtn = YES;
    self.indicatorType = IndicatorTypeCyclingCycle2;
    self.isShowTool = YES;
    
    self.layer.masksToBounds = YES; // 切除超过父视图
}

#pragma mark - <************************** 初始化 **************************>

-(PLPlayerOption *)option{
    if (_option==nil) {
        _option = [PLPlayerOption defaultOption];
        [_option setOptionValue:@15 forKey:PLPlayerOptionKeyTimeoutIntervalForMediaPackets];
        [_option setOptionValue:@2000 forKey:PLPlayerOptionKeyMaxL1BufferDuration];
        [_option setOptionValue:@1000 forKey:PLPlayerOptionKeyMaxL2BufferDuration];
        [_option setOptionValue:@(NO) forKey:PLPlayerOptionKeyVideoToolbox];
        [_option setOptionValue:@(kPLLogError) forKey:PLPlayerOptionKeyLogLevel];
    }
    return _option;
}

-(PLPlayer *)player{
    if (_player==nil) {
        NSURL *url = [NSURL URLWithString:self.urlString];
        _player = [PLPlayer playerLiveWithURL:url option:self.option];
        _player.delegate = self;
        _player.playerView.frame = self.bounds;
        _player.autoReconnectEnable = YES;
    }
    return _player;
}

-(IndicatorView *)loading{
    if (_loading==nil) {
        _loading = [[IndicatorView alloc] initWithType:self.indicatorType tintColor:KColorTheme size:CGSizeMake(30, 30)];
        [self addSubview:_loading];
        [_loading cwn_makeConstraints:^(UIView *maker) {
            maker.centerXtoSuper(0).centerYtoSuper(0);
        }];
    }
    return _loading;
}


#pragma mark - <************************** 七牛播放器的代理方法 **************************>
// !!!: 播放状态回调
- (void)player:(nonnull PLPlayer *)player statusDidChange:(PLPlayerStatus)state{
    NSLog(@"当前播放状态：%ld",(long)state);
    if (state==PLPlayerStatusPlaying||state==PLPlayerStatusPaused||state==PLPlayerStatusStopped||state==PLPlayerStatusError) {
        if (self.loading.isAnimating) {
            [self.loading stopAnimating];
        }
    }
    else if (state==PLPlayerStatusCompleted){
        NSLog(@"播放完成");
    }
    else{
        NSLog(@"加载中...");
        if (self.loading.isAnimating==NO) {
            [self.loading startAnimating];
        }
    }
    
    
    if (self.isSliding==NO) {
        // 设置按钮样式
        if (state==PLPlayerStatusPlaying) {     // 在播放
            [self.playOrStopBtn setImage:[UIImage imageNamed:@"Player_pause"] forState:UIControlStateNormal];
        }
        else{
            [self.playOrStopBtn setImage:[UIImage imageNamed:@"Player_play"] forState:UIControlStateNormal];
        }
    }
}

// !!!: 错误状态回调
- (void)player:(nonnull PLPlayer *)player stoppedWithError:(nullable NSError *)error{
    NSLog(@"error:%@",error.localizedDescription);
}

// !!!: 缓存进度
- (void)player:(nonnull PLPlayer *)player loadedTimeRange:(CMTimeRange)timeRange{
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval totalBuffer = startSeconds + durationSeconds; //缓冲总长度
    NSLog(@"\nstartSeconds:%.2f\ndurationSeconds:%.2f\ntotalBuffer:%.2f",startSeconds,durationSeconds,totalBuffer);
//    [self.progressView setProgress:(totalBuffer/self.progressSlider.maximumValue) animated:YES];
}




#pragma mark - <************************** 私有方法 **************************>
// 设置视频地址
-(void)setUrlString:(NSString *)urlString{
    _urlString = urlString;
    if (self.isAutoPlay) {
        [self play];
    }
}
// 设置是否自动播放
-(void)setIsAutoPlay:(BOOL)isAutoPlay{
    _isAutoPlay = isAutoPlay;
    if (isAutoPlay&&self.urlString) {
        [self play];
    }
}


/**
 从头开始播放视频
 */
-(void)play{
    [self addSubview:self.player.playerView];
    [self sendSubviewToBack:self.player.playerView];
    [self.player.playerView cwn_makeConstraints:^(UIView *maker) {
        maker.leftToSuper(0).rightToSuper(0).topToSuper(0).bottomToSuper(0);
    }];
    [self.player play];

    [self.playTimer invalidate];
    self.playTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateCurrentTime) userInfo:nil repeats:YES];
}

/**
 停止
 */
-(void)stop{
    if (self.isSliding==NO) {   // 如果没有在拖动中再旋转释放定时器
        // 定时器释放
        [self releaseTimer:self.playTimer];
        [self releaseTimer:self.toolTimer];
    }
    [self.player stop];
}


/**
 暂停
 */
-(void)pause{
    [self.player pause];
    // 暂停定时器
    [self pauseTimer:self.playTimer];
}

/**
 恢复视频
 */
-(void)resume{
    [self.player resume];
    // 恢复定时器
    [self resumeTimer:self.playTimer];
}


// 播放定时
-(void)updateCurrentTime{
    if (self.isSliding) {
        return;
    }
    CGFloat currentTime = CMTimeGetSeconds(self.player.currentTime);
    CGFloat totalTime = CMTimeGetSeconds(self.player.totalDuration);
    self.beginLabel.text = [self convertTime:currentTime];;
    self.endLabel.text = [self convertTime:totalTime];
    self.progressSlider.maximumValue = totalTime;
    [self.progressSlider setValue:currentTime animated:YES];
    NSLog(@"\n当前时间:%.2f\n总共时间:%.2f",currentTime,totalTime);
}


// !!!: 滑动视图
-(void)onSliderTouchedDown:(id)sender{
    self.isSliding = YES;
    [self pauseTimer:self.toolTimer];
}
-(void)onSliderTouchedUp:(id)sender{
    self.isSliding = NO; // 滑动结束
    [self resumeTimer:self.toolTimer];
    UISlider *slider = (UISlider *)sender;
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1.0);
    [self.player seekTo:changedTime];
    if (slider.value<slider.maximumValue) {
        [self.playOrStopBtn setImage:[UIImage imageNamed:@"Player_pause"] forState:UIControlStateNormal];
    }
}
- (void)sliderValueChanged:(id)sender {
    self.isSliding = YES;
    [self pauseTimer:self.toolTimer];
    UISlider *slider = (UISlider *)sender;
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1.0);
    float currentTime = CMTimeGetSeconds(changedTime);
    self.beginLabel.text = [self convertTime:currentTime];
}


// !!!: 时间转换
- (NSString *)convertTime:(CGFloat)second {
    // 相对格林时间
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:second];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    if (second / 3600 >= 1) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    }
    
    NSString *showTimeNew = [formatter stringFromDate:date];
    return showTimeNew;
}


#pragma mark - <************************** 点击事件 **************************>
// !!!: 播放或暂停事件
-(void)playOrStopBtnAction{
    if (self.player.isPlaying) {    // 正在播放
        [self pause];       // 暂停
    }
    else{
        [self resume];      // 恢复
    }
}
// !!!: 全屏按钮
-(void)fullscreenBtnAction:(UIButton*)fullscreenBtn{
    if ([RotationScreen isOrientationLandscape]) { // 如果是横屏，
        [RotationScreen forceOrientation:(UIInterfaceOrientationPortrait)]; // 切换为竖屏
    } else {
        [RotationScreen forceOrientation:(UIInterfaceOrientationLandscapeRight)]; // 否则，切换为横屏
    }
}
// !!!: 返回按钮
- (IBAction)goBackBtn:(UIButton *)sender {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(moviePlayerViewGoBackEvent:)]) {
        [self.delegate moviePlayerViewGoBackEvent:self];
    }
    [self stop];
}

// !!!: 收展工具栏
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if (!self.isShowTool) {
        [self.toolTimer invalidate];
        self.toolTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(hideTool) userInfo:nil repeats:NO];
    }
    
    [self hideTool:_isShowTool];
}

#pragma mark - <************************** 其他 **************************>
// !!!: 设置请求头部
-(void)setReferer:(NSString *)referer{
    _referer = referer;
    if (referer.length) {
        self.player.referer = referer;
        if (self.isAutoPlay) {
            [self play];
        }
    }
}

// !!!: 设置全屏按钮
-(void)setNeedFullScreenBtn:(BOOL)needFullScreenBtn{
    _needFullScreenBtn = needFullScreenBtn;
    self.fullscreenBtn.hidden = !needFullScreenBtn;
}

// !!!: 设置标题
-(void)setMovieTitle:(NSString *)movieTitle{
    _movieTitle = movieTitle;
    self.titlelabel.text = movieTitle;
}

// !!!: 屏幕旋转方向
- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation{
    
    UIDevice *device = [UIDevice currentDevice] ;
    switch (device.orientation) {
        case UIDeviceOrientationFaceUp:
            NSLog(@"屏幕朝上平躺");
            break;
        case UIDeviceOrientationFaceDown:
            NSLog(@"屏幕朝下平躺");
            break;
        case UIDeviceOrientationUnknown:
            NSLog(@"未知方向");
            break;
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"home键在右");
            [self.fullscreenBtn setImage:[UIImage imageNamed:@"Player_shrinkscreen"] forState:UIControlStateNormal];
            break;
        case UIDeviceOrientationLandscapeRight:
            NSLog(@"home键在左");
            [self.fullscreenBtn setImage:[UIImage imageNamed:@"Player_shrinkscreen"] forState:UIControlStateNormal];
            break;
        case UIDeviceOrientationPortrait:
            NSLog(@"home键在下");
            [self.fullscreenBtn setImage:[UIImage imageNamed:@"Player_fullscreen"] forState:UIControlStateNormal];
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"home键在上");
            break;
        default:
            NSLog(@"无法辨识");
            break;
    }
}


// !!!: 显隐藏工具栏
-(void)hideTool{
    [self hideTool:YES];
}
-(void)hideTool:(BOOL)isHide{
    if (isHide) {
        [UIView animateWithDuration:0.25 animations:^{
            if (CGAffineTransformIsIdentity(self.topView.transform)) {
                self.topView.transform = CGAffineTransformTranslate(self.topView.transform, 0, -self.topView.frame.size.height);
            }
            if (CGAffineTransformIsIdentity(self.bottomView.transform)) {
                self.bottomView.transform = CGAffineTransformTranslate(self.bottomView.transform, 0, self.bottomView.frame.size.height);
            }
        } completion:^(BOOL finished) {
            self.isShowTool = NO;
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.topView.transform = CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.isShowTool = YES;
        }];
    }
}



// 暂停定时器
-(void)pauseTimer:(NSTimer*)timer{
    if (timer) {
        [timer setFireDate:[NSDate distantFuture]];
    }
}
// 恢复定时器
-(void)resumeTimer:(NSTimer*)timer{
    if (timer) {
        [timer setFireDate:[NSDate distantPast]];
    }
}

// 释放定时器
-(void)releaseTimer:(NSTimer*)timer{
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}



// !!!: 释放检测
-(void)dealloc{
    NSLog(@"%@释放了...",self.class);
}

@end
