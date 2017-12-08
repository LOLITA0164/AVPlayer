//
//  ViewController.m
//  AVPlayer
//
//  Created by LOLITA on 2017/11/28.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayerViewController.h"
#import "MoviePlayerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    [btn setTitle:@"点击" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor purpleColor];
    btn.center = self.view.center;
    
    [self.view addSubview:btn];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
   
}

-(void)btnAction{
//    VideoPlayerViewController *ctrl = [[VideoPlayerViewController alloc] initWithNibName:@"VideoPlayerViewController" bundle:nil];
//    ctrl.urlString = @"http://hcluploadffiles.oss-cn-hangzhou.aliyuncs.com/环保小视频.mp4";
//    ctrl.videoTitle = @"环保小视频";
//    [self presentViewController:ctrl animated:YES completion:nil];
    
    MoviePlayerViewController *ctrl = [[MoviePlayerViewController alloc] initWithNibName:@"MoviePlayerViewController" bundle:nil];
    ctrl.movieUrlString = @"http://hcluploadffiles.oss-cn-hangzhou.aliyuncs.com/环保小视频.mp4";
    ctrl.movieUrlString = [ctrl.movieUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ctrl.movieTitle = @"小视频";
    [self presentViewController:ctrl animated:YES completion:nil];
}



// 开启自动转屏
- (BOOL)shouldAutorotate {
    return NO;
}
// 设备支持方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
