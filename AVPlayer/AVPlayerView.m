//
//  AVPlayerView.m
//  AVPlayer
//
//  Created by LOLITA on 2017/12/1.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#define kTimerDuration  5

#import "AVPlayerView.h"

@interface AVPlayerView()
{
    BOOL _isShowTool;   // 是否显示工具栏
}
@property (strong ,nonatomic) AVPlayer *player;                 //播放器对象
@property (strong ,nonatomic) AVPlayerLayer *playerLayer;       // 可视图层

@property (weak, nonatomic) IBOutlet UIView *restartView;       // 重播视图
- (IBAction)restartBtn:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UIView *topView;           // 顶部视图
@property (weak, nonatomic) IBOutlet UIView *bottomView;        // 底部视图

@property (weak, nonatomic) IBOutlet UIButton *gobackBtn;       // 返回按钮
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;       // 标题
@property (weak, nonatomic) IBOutlet UISlider *progressView;    // 进度
@property (weak, nonatomic) IBOutlet UILabel *startLabel;       // 开始
@property (weak, nonatomic) IBOutlet UILabel *endLabel;         // 结束
@property (weak, nonatomic) IBOutlet UIButton *startOrEndBtn;   // 暂停播放按钮

@property (copy ,nonatomic) NSString *urlString;                // 播放地址
@property (strong ,nonatomic) NSTimer *timer;

@property (assign ,nonatomic) BOOL shouldResumeAfterInterrupted;    // 是否需要恢复，如果是主动打断，则不需要

@property (strong ,nonatomic) UIActivityIndicatorView *loading;
@property (assign ,nonatomic) BOOL isSliding;                   // 是否正在滑动

@end

@implementation AVPlayerView


-(void)awakeFromNib{
    [super awakeFromNib];
    
    self.shouldResumeAfterInterrupted = YES;
    
    [self.layer addSublayer:self.playerLayer];
    
    _isShowTool = YES;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(hideTool) userInfo:nil repeats:NO];
    
    // 进度
    [self.progressView setThumbImage:[UIImage imageNamed:@"sliderTracing"] forState:UIControlStateNormal];
    [self.progressView addTarget:self action:@selector(onSliderTouchedDown) forControlEvents:UIControlEventTouchDown];
    [self.progressView addTarget:self action:@selector(onSliderTouchedUp) forControlEvents:UIControlEventTouchUpInside];
    [self.progressView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];// 针对值变化添加响应方法
    
    // 按钮事件
    [self.gobackBtn addTarget:self action:@selector(gobackBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.startOrEndBtn addTarget:self action:@selector(startOrEndBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self bringSubviewToFront:self.restartView];
    [self bringSubviewToFront:self.topView];
    [self bringSubviewToFront:self.bottomView];
    
    [self addSubview:self.loading];
    [self bringSubviewToFront:self.loading];
    [self.loading startAnimating];
    
}

-(void)playWithUrlString:(NSString *)urlString{
    self.urlString = urlString;
    [self.player replaceCurrentItemWithPlayerItem:[self playerItem]];
}

#pragma mark - <************************** 播放器等初始化部分 **************************>

// !!!: 视频数据
-(AVPlayerItem *)playerItem{
    NSMutableDictionary *headers = [NSMutableDictionary dictionary];
    [headers setObject:@"zhibo.zfxfu.com"forKey:@"Referer"];
    self.urlString = [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:self.urlString] options:@{@"AVURLAssetHTTPHeaderFieldsKey" : headers}];
    // 初始化playerItem
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    // 添加相关状态监听
    // 状态
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    // 加载进度
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    return playerItem;
}
// !!!: 播放器
-(AVPlayer *)player{
    if (_player==nil) {
        _player = [AVPlayer playerWithPlayerItem:[self playerItem]];
        //这里设置1/10秒执行一次
        WS(ws);
        [_player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            float current = CMTimeGetSeconds(time);
            if (current&&ws.isSliding==NO) {
                [ws updateVideoSlider:current];
            }
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        //监听音乐被打断，继续播放
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionInterrupted:) name:AVAudioSessionInterruptionNotification object:nil];
        //接收音频源改变监听事件，比如更换了输出源，由耳机播放拔掉耳机后，应该把音乐暂停(参照酷狗应用)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(routeChange:) name:AVAudioSessionRouteChangeNotification object:nil];
        // 前台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        // 后台通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return _player;
}
// !!!: 播放器视图
-(AVPlayerLayer *)playerLayer{
    if (_playerLayer==nil) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;//视频填充模式
    }
    return _playerLayer;
}


-(void)setVideoTitle:(NSString *)videoTitle{
    _videoTitle = videoTitle;
    self.titleLabel.text = _videoTitle;
}


-(UIActivityIndicatorView *)loading{
    if (_loading==nil) {
        _loading = [[UIActivityIndicatorView alloc] initWithFrame:self.bounds];
        _loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        _loading.color = [UIColor redColor];
    }
    return _loading;
}


#pragma mark - <************************** 操作事件 **************************>
// !!!: 滑动视图
-(void)onSliderTouchedDown{
    self.isSliding = YES;
    [self pause];
}
-(void)onSliderTouchedUp{
    self.isSliding = NO; // 滑动结束
    [self play];
}
- (void)sliderValueChanged:(id)sender {
    self.isSliding = YES;
    [self pause];
    UISlider *slider = (UISlider *)sender;
    CMTime changedTime = CMTimeMakeWithSeconds(slider.value, 1.0);
    float current = CMTimeGetSeconds(changedTime);
    [self updateVideoSlider:current];
    [self.player.currentItem seekToTime:changedTime];
}

// 更新滑动条
- (void)updateVideoSlider:(float)currentTime{
    [self.progressView setValue:currentTime animated:YES];
    self.startLabel.text = [self convertTime:currentTime];
    if (currentTime&&self.isPlaying) {
        self.restartView.hidden = YES;
    }
}

// 返回
-(void)gobackBtnAction{
    NSLog(@"返回...");
    [self.timer invalidate];
    self.timer = nil;
    if (self.gobackBlock) {
        self.gobackBlock();
    }
}

// 暂停或开始
-(void)startOrEndBtnAction{
    if (self.isPlaying) {
        [self pause];
        self.shouldResumeAfterInterrupted = NO; // 主动打断
    } else {
        [self play];
        self.shouldResumeAfterInterrupted = YES;    //
    }
}


#pragma mark - <************************** 通知 **************************>

// !!!: KVO监听的播放器状态
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *playerItem = object;
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerStatus status = [[change objectForKey:@"new"] intValue];
            if(status==AVPlayerItemStatusReadyToPlay){
                NSLog(@"正在播放...，视频总长度:%.2f",CMTimeGetSeconds(playerItem.duration));
                self.progressView.maximumValue = CMTimeGetSeconds(playerItem.duration);
                self.endLabel.text = [self convertTime:CMTimeGetSeconds(playerItem.duration)];
                if (self.shouldResumeAfterInterrupted) {
                    [self play];
                }
                [self.loading stopAnimating];
            }else if (status==AVPlayerItemStatusFailed){
                NSLog(@"失败");
                [self pause];
            }
            else if (status==AVPlayerItemStatusUnknown){
                NSLog(@"未知");
                [self pause];
            }
        }else if([keyPath isEqualToString:@"loadedTimeRanges"]){
            NSArray *array = playerItem.loadedTimeRanges;
            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue];//本次缓冲时间范围
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            NSTimeInterval totalBuffer = startSeconds + durationSeconds;//缓冲总长度
            NSLog(@"共缓冲：%.2f",totalBuffer);
            // 设置缓存
        }
    }
}


// !!!: 视频播放完成
-(void)playbackFinished:(NSNotification *)notification{
    NSLog(@"视频播放完成.");
    // 显示重播视图
    self.isPlaying = NO;
    self.restartView.hidden = NO;
    self.shouldResumeAfterInterrupted = NO;
}

// !!!: 监听音乐打断处理(如某个电话来了、电话结束了)
- (void)audioSessionInterrupted:(NSNotification *)notification{
    NSDictionary * info = notification.userInfo;
    if ([[info objectForKey:AVAudioSessionInterruptionTypeKey] integerValue] == 1) {//被打断
        [self pause];
    }else{//打断结束
        if(self.shouldResumeAfterInterrupted == YES)
            [self play];
    }
}

// !!!: 监听音频源改变监听事件，比如更换了输出源，由耳机播放拔掉耳机后，应该把音乐暂停(参照酷狗应用)
-(void)routeChange:(NSNotification *)notification{
    NSDictionary *dic=notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason==AVAudioSessionRouteChangeReasonOldDeviceUnavailable) {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机说明由耳机拔出来了，则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"]) {
            [self pause];
        }
    }
}

// 进入前台
-(void)enterForegroundNotification:(NSNotification *)notification{
    if (self.shouldResumeAfterInterrupted == YES) {
        [self play];
    }
}

// 进入后台
-(void)enterBackgroundNotification:(NSNotification *)notification{
    [self pause];
}



#pragma mark - <************************** 其他 **************************>

- (void)play {
    self.isPlaying = YES;
    [self.player play]; // 调用avplayer 的play方法
    [self.startOrEndBtn setImage:[UIImage imageNamed:@"Player_pause"] forState:(UIControlStateNormal)];
}

- (void)pause {
    self.isPlaying = NO;
    [self.player pause];
    [self.startOrEndBtn setImage:[UIImage imageNamed:@"Player_play"] forState:(UIControlStateNormal)];
}

// 重播事件
- (IBAction)restartBtn:(UIButton *)sender {
    [self.player.currentItem seekToTime:kCMTimeZero]; // 跳转到初始
    [self play];  // 继续播放
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(hideTool) userInfo:nil repeats:NO];
}


// !!!: 收展工具栏
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.timer) {
        [self.timer invalidate];
    }
    
    if (!_isShowTool) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerDuration target:self selector:@selector(hideTool) userInfo:nil repeats:NO];
    }
    
    [self hideTool:_isShowTool];
}
-(void)hideTool{
    [self hideTool:YES];
}
-(void)hideTool:(BOOL)isHide{
    if (isHide) {
        [UIView animateWithDuration:0.25 animations:^{
            self.topView.transform = CGAffineTransformTranslate(self.topView.transform, 0, self.topView.frame.origin.y-self.topView.frame.size.height);
            self.bottomView.transform = CGAffineTransformTranslate(self.bottomView.transform, 0, self.bottomView.frame.origin.y+self.bottomView.frame.size.height);
        } completion:^(BOOL finished) {
            _isShowTool = NO;
        }];
    }else{
        [UIView animateWithDuration:0.25 animations:^{
            self.topView.transform = CGAffineTransformIdentity;
            self.bottomView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _isShowTool = YES;
        }];
    }
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


// !!!: 获取当前时间
- (NSString *)getCurrentTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"mm:ss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    return currentTime;
}



#pragma mark - <************************** 释放 **************************>
-(void)dealloc{
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
