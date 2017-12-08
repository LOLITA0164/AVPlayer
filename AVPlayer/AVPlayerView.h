//
//  AVPlayerView.h
//  AVPlayer
//
//  Created by LOLITA on 2017/12/1.
//  Copyright © 2017年 LOLITA0164. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

@interface AVPlayerView : UIView

@property (nonatomic, assign) BOOL isPlaying;   // 是否正在播放

@property (copy ,nonatomic) NSString *videoTitle;   // 视频标题

@property (nonatomic,copy) void(^gobackBlock)();    // 回调返回信息

-(void)playWithUrlString:(NSString*)urlString;  // 视频地址

@end
