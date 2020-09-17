//
//  nnWaveformPlayerView.h
//
//  Created by Cady Holmes on 9/11/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//


//  Extended from:
//  SYWaveformPlayerView.h
//  SCWaveformView
//
//  Created by Spencer Yen on 12/26/14.
//  Copyright (c) 2014 Simon CORSIN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SCWaveformView.h"

@protocol nnWaveformPlayerViewDelegate;
@interface nnWaveformPlayerView : UIView <AVAudioPlayerDelegate, UIGestureRecognizerDelegate>
{
    BOOL shouldPlay;
}

@property (nonatomic, weak) id<nnWaveformPlayerViewDelegate> delegate;
@property (nonatomic, strong) SCWaveformView *waveformView;
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic) BOOL loops;

- (id)initWithFrame:(CGRect)frame asset:(AVURLAsset *)asset color:(UIColor *)normalColor progressColor:(UIColor *)progressColor;
- (void)updateWaveform:(id)sender;
- (void)play;
- (void)pause;
- (void)stop;

@end

@protocol nnWaveformPlayerViewDelegate <NSObject>
- (void)progressDidChange:(nnWaveformPlayerView *)player;
- (void)didReceiveTouch:(UIGestureRecognizer *)sender;
- (void)didStartPlaying:(nnWaveformPlayerView *)player;
- (void)didPausePlaying:(nnWaveformPlayerView *)player;
- (void)didStopPlaying:(nnWaveformPlayerView *)player;
- (void)playerDidFinish:(nnWaveformPlayerView *)player successfully:(BOOL)flag;
@end
