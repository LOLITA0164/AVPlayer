//
//  MoviePlayerViewController.h
//  AVPlayer
//
//  Created by LOLITA on 2017/12/7.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoviePlayerView.h"

@interface MoviePlayerViewController : UIViewController

@property (copy ,nonatomic) NSString *movieUrlString;

@property (copy ,nonatomic) NSString *movieTitle;

@property (strong ,nonatomic) MoviePlayerView *moviePlayer;     // 播放器

@end
