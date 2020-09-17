//
//  nnWaveformPlayerView.m
//
//  Created by Cady Holmes on 9/11/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "nnWaveformPlayerView.h"

@implementation nnWaveformPlayerView

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
//    return YES;
//}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

- (id)initWithFrame:(CGRect)frame asset:(AVURLAsset *)asset color:(UIColor *)normalColor progressColor:(UIColor *)progressColor {
    if (self = [super initWithFrame:frame]) {
        
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:asset.URL error:nil];
        self.player.delegate = self;
        
        self.waveformView = [[SCWaveformView alloc] init];
        self.waveformView.normalColor = normalColor;
        self.waveformView.progressColor = progressColor;
        self.waveformView.alpha = 0.8;
        self.waveformView.backgroundColor = [UIColor clearColor];
        self.waveformView.asset = asset;
        
        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [lp setMinimumPressDuration:0.000000001];
        [self addGestureRecognizer:lp];
        [lp setDelegate:self];
        
        [self addSubview:self.waveformView];
        
        //[self.player setVolume:0];
        //[self.player play];
        
        [NSTimer scheduledTimerWithTimeInterval:0.1 target: self
                                       selector: @selector(updateWaveform:) userInfo: nil repeats: YES];
        
    }
    
    return self;
}

//- (void)setURL:(AVURLAsset*)asset {
//    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:asset.URL error:nil];
//}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.waveformView.frame = CGRectMake(10, 0, self.frame.size.width - 20, self.frame.size.height);
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (self.player.isPlaying) {
            shouldPlay = YES;
        }
        [self pause];
    } else if (sender.state == UIGestureRecognizerStateCancelled | sender.state == UIGestureRecognizerStateEnded) {
        NSTimeInterval newTime = self.waveformView.progress * self.player.duration;
        self.player.currentTime = newTime;
        if (shouldPlay) {
            [self play];
            shouldPlay = NO;
        }
    }
    
    CGPoint location = [sender locationInView:self];
    
    if(location.x/self.frame.size.width > 0) {
        self.waveformView.progress = location.x/self.frame.size.width;
        self.waveformView.progress = MAX(0, MIN(1.0, self.waveformView.progress));
        
        //NSLog(@"%f %f",location.x, self.waveformView.progress);
        id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(didReceiveTouch:)]) {
            [strongDelegate didReceiveTouch:sender];
        }
    }
}

/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchesMoved:touches withEvent:event];
    [self pause];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [[event allTouches]anyObject];
    CGPoint location = [touch locationInView:self];
    
    if(location.x/self.frame.size.width > 0) {
        self.waveformView.progress = location.x/self.frame.size.width;
        self.waveformView.progress = MAX(0, MIN(1.0, self.waveformView.progress));
        
        //NSLog(@"%f %f",location.x, self.waveformView.progress);
        
        id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(progressDidChange:)]) {
            [strongDelegate progressDidChange:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSTimeInterval newTime = self.waveformView.progress * self.player.duration;
    self.player.currentTime = newTime;
    [self play];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    NSTimeInterval newTime = self.waveformView.progress * self.player.duration;
    self.player.currentTime = newTime;
    [self play];
}
*/

- (void)play {
    [self.player play];
    id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(didStartPlaying:)]) {
        [strongDelegate didStartPlaying:self];
    }
}

- (void)pause {
    [self.player pause];
    id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(didPausePlaying:)]) {
        [strongDelegate didPausePlaying:self];
    }
}

- (void)stop {
    [self.player stop];
    id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(didStopPlaying:)]) {
        [strongDelegate didStopPlaying:self];
    }
}

- (void)updateWaveform:(id)sender {
    if(self.player.playing) {
        self.waveformView.progress = self.player.currentTime/self.player.duration;
    }
    
    id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(progressDidChange:)]) {
        [strongDelegate progressDidChange:self];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    [self.player stop];
    id<nnWaveformPlayerViewDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(playerDidFinish:successfully:)]) {
        [strongDelegate playerDidFinish:self successfully:flag];
    }
    if (self.loops) {
        [self.player prepareToPlay];
        [self.player play];
    }
}
@end
