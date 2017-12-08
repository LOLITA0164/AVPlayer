//
//  VideoPlayerViewController.m
//  AVPlayer
//
//  Created by LOLITA on 2017/12/1.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#define kSCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define kSCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define kSCREEN_WIDTH_LANDSCAPE MAX(kSCREEN_WIDTH, kSCREEN_HEIGHT)
#define kSCREEN_HEIGHT_LANDSCAPE MIN(kSCREEN_WIDTH, kSCREEN_HEIGHT)

#import "VideoPlayerViewController.h"
#import "AVPlayerView.h"

@interface VideoPlayerViewController ()
@property (strong ,nonatomic) AVPlayerView *avPlayer;
@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.view addSubview:self.avPlayer];
    WS(ws);
    self.avPlayer.gobackBlock = ^{
        [ws dismissViewControllerAnimated:YES completion:nil];
    };
    
}

-(AVPlayerView *)avPlayer{
    if (_avPlayer==nil) {
        _avPlayer = [[[NSBundle mainBundle] loadNibNamed:@"AVPlayerView" owner:nil options:nil] firstObject];
        _avPlayer.frame = self.view.bounds;
        _avPlayer.videoTitle = self.videoTitle;
        [_avPlayer playWithUrlString:self.urlString];
    }
    return _avPlayer;
}


#pragma mark - <************************** 其他方法 **************************>
// 开启自动转屏
- (BOOL)shouldAutorotate {
    return YES;
}
// 设备支持方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}
// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

-(void)dealloc{
    NSLog(@"%@释放了",self.class);
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
