//
//  MoviePlayerViewController.m
//  AVPlayer
//
//  Created by LOLITA on 2017/12/7.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#import "MoviePlayerViewController.h"

@interface MoviePlayerViewController ()<MoviePlayerViewDelegate>

// !!!: 视频类
@property (weak, nonatomic) IBOutlet UIView *contentView;


@end

@implementation MoviePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.contentView addSubview:self.moviePlayer];
    [self.moviePlayer cwn_makeConstraints:^(UIView *maker) {
        maker.leftToSuper(0).rightToSuper(0).topToSuper(0).bottomToSuper(0);
    }];
    
}


// !!!: 视频初始化
-(MoviePlayerView *)moviePlayer{
    if (_moviePlayer==nil) {
        _moviePlayer = [[[NSBundle mainBundle] loadNibNamed:@"MoviePlayerView" owner:nil options:nil] firstObject];
        _moviePlayer.movieTitle = self.movieTitle;
        _moviePlayer.urlString = self.movieUrlString;
        _moviePlayer.needFullScreenBtn = NO;
        _moviePlayer.delegate = self;
        _moviePlayer.referer = @"Referer:http://zhibo.zfxfu.com";
        _moviePlayer.isAutoPlay = YES;
    }
    return _moviePlayer;
}



#pragma mark - <************************** 播放视图代理事件 **************************>
-(void)moviePlayerViewGoBackEvent:(MoviePlayerView *)playerView{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - <************************** 系统屏幕事件事件 **************************>
-(BOOL)shouldAutorotate{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}


#pragma mark - <************************** 释放检测 **************************>

-(void)dealloc{
    NSLog(@"%@释放了...",self.class);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
