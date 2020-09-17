//
//  PlayerViewController.m
//
//  Created by Cady Holmes on 12/16/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "PlayerViewController.h"
#import "nnKit.h"
#import "nnMediaPickerPopUp.h"
#import "nnWaveformPlayerView.h"
#import "MarqueeLabel.h"
#import "UIColor+NNColors.h"
#import "MONActivityIndicatorView.h"
#import "NNToggle.h"
#import "PassThroughView.h"
#import "NNSlider.h"

@interface PlayerViewController () <nnMediaPickerPopUpDelegate, nnWaveformPlayerViewDelegate, MONActivityIndicatorViewDelegate,NNToggleDelegate>
{
    nnMediaPickerPopUp *popup;
    nnWaveformPlayerView *waveView;
    MONActivityIndicatorView* spinner;
    NSArray* colorTheme;
    
    int currentSong;
    int lastSong;
    int songCount;
    
    UIButton *playButton;
    UIButton *menuButton;
    UIButton *homeButton;
    UIButton *questionButton;
    UIButton *ffButton;
    UIButton *rwButton;
    
    UIView *closeView;
    UIView *popupView;
    UIView *parentView;
    PassThroughView *upperView;
    
    UILabel *placeholder;
    
    //BOOL adsRemoved;
//    GADBannerView *bannerView;
//    GADInterstitial *interstitial;
//    BOOL bannerIsVisible;
    CGFloat iAdHeight;
    
    CGFloat waveViewHeight;
    
    MarqueeLabel *titleLabel;
    MarqueeLabel *artistLabel;
    MarqueeLabel *albumLabel;
    
    NNToggle *shuffleToggle;
    NNToggle *loopToggle;
    BOOL shuffles;
    BOOL loops;
    NSMutableArray *shuffleArray;
    
    UIColor *fontColor;
    int themeID;
    
    NNSlider *volSlider;
    CGFloat vol;
    
    BOOL hasHelp;
    BOOL hasTransport;
    BOOL playingDuringInterruption;
    BOOL playing;
    NSTimer *timer;
    
    UILabel *menuHelp;
    UILabel *menuHelp2;
    UILabel *menuHelp3;
    UILabel *menuHelp4;
    UILabel *homeHelp;
    UILabel *questionHelp;
    UILabel *metaHelp;
    UILabel *waveHelp;
    UILabel *transportHelp;
    UILabel *loopHelp;
    UILabel *volumeHelp;
    UILabel *volumeHelp2;
    
//    BOOL testAds;
}

@end

@implementation PlayerViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)onAudioInterruption:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *info = notification.userInfo;
        NSUInteger type = [[info valueForKey:AVAudioSessionInterruptionTypeKey] unsignedIntegerValue];
        if (type == AVAudioSessionInterruptionTypeBegan) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (playing) {
                    playingDuringInterruption = YES;
                    //[waveView pause];
                    //[self handlePlay:playButton];
                }
            });
        } else if (type == AVAudioSessionInterruptionTypeEnded) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (playingDuringInterruption) {
                    playingDuringInterruption = NO;
                    //[playButton setBackgroundImage:[UIImage imageNamed:@"play.pdf"] forState:UIControlStateNormal];
                    [waveView play];
                    //[self handlePlay:playButton];
                }
            });
        }
    });
}

- (void)appWillEnterForeground:(NSNotificationCenter*)note {
    if (spinner) {
        [self handleSpinner];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (playing) {
            [nnKit animatePulse:playButton.layer];
        }
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adsRemoved = YES;
//
//    NSLog(@"Google Mobile Ads SDK version: %@", [GADRequest sdkVersion]);
//
//    testAds = YES;
    
    // Remote control still doesnt work.
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAudioInterruption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    themeID = 1;
    vol = 1.;

    iAdHeight = 50;
    if ([nnKit isIPad]) {
        iAdHeight = 90;
    }
    //check iPad - might be 66 or something like that
    
    waveViewHeight = SH()*.375;
    if ([nnKit isIPhone4] || [nnKit isIPad]) {
        waveViewHeight = SH()*.3;
    }

    [self startupUI];
    
    shuffleArray = [[NSMutableArray alloc] init];
}

- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"appear");
    CGFloat sysVol = [[AVAudioSession sharedInstance] outputVolume];
    if (sysVol < .4) {
        [self showVolumeAlert];
    }
}

- (void)showVolumeAlert {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Device Volume is Low"
                                                                             message: @"Make sure your device's volume is turned up enough!"
                                                                      preferredStyle:UIAlertControllerStyleAlert                   ];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Thanks"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alertController dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    
    UIViewController *currentTopVC = [nnKit currentTopViewController];
    [alertController addAction: ok];
    [currentTopVC presentViewController:alertController animated:YES completion:nil];
}

- (void)startupUI {
    NSArray *theme = [nnKit handleColorsForSimplyMusic:themeID];;
    fontColor = [theme objectAtIndex:1];
    
    parentView = [[UIView alloc] initWithFrame:self.view.frame];
    //parentView.backgroundColor = [UIColor flatBlackColor];
    parentView.backgroundColor = [theme objectAtIndex:0];
    
    CGFloat buttonSize = SW()/6;
    menuButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"menuIcon.pdf"] frame:CGRectMake(0, 30, buttonSize, buttonSize) method:@"showPickerPopup:" fromClass:self];
    [menuButton setCenter:CGPointMake(SW()/5, menuButton.center.y)];
    
    homeButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"home.pdf"] frame:CGRectMake(0, 30, buttonSize, buttonSize) method:@"goBack:" fromClass:self];
    [homeButton setCenter:CGPointMake(SW()/2, homeButton.center.y)];
    
    questionButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"question.pdf"] frame:CGRectMake(0, 30, buttonSize, buttonSize) method:@"handleQuestion:" fromClass:self];
    [questionButton setCenter:CGPointMake(SW()-(SW()/5), questionButton.center.y)];
    
    [parentView addSubview:menuButton];
    [parentView addSubview:homeButton];
    [parentView addSubview:questionButton];
    
    CGFloat dur = 25.;
    CGFloat len = 10;
    CGFloat labelFontSize = SW()/20;
    CGFloat labelYOffset = SH()/5.1;
    CGFloat labelBuffer = labelFontSize*1.85;
    
    titleLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(10, labelYOffset, SW()-20, labelFontSize*1.1) duration:dur andFadeLength:len];
    titleLabel.font = [UIFont fontWithName:[nnKit getGlobalFont] size:labelFontSize];
    artistLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(10, labelYOffset+labelBuffer, SW()-20, labelFontSize*1.1) duration:dur andFadeLength:len];
    artistLabel.font = [UIFont fontWithName:[nnKit getGlobalFont] size:labelFontSize];
    albumLabel = [[MarqueeLabel alloc] initWithFrame:CGRectMake(10, labelYOffset+(labelBuffer*2), SW()-20, labelFontSize*1.1) duration:dur andFadeLength:len];
    albumLabel.font = [UIFont fontWithName:[nnKit getGlobalFont] size:labelFontSize];

    titleLabel.textColor = fontColor;
    artistLabel.textColor = fontColor;
    albumLabel.textColor = fontColor;
    
    titleLabel.marqueeType = MLContinuous;
    artistLabel.marqueeType = MLContinuous;
    albumLabel.marqueeType = MLContinuous;
    
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [artistLabel setTextAlignment:NSTextAlignmentCenter];
    [albumLabel setTextAlignment:NSTextAlignmentCenter];
    
    titleLabel.text = @"title";
    artistLabel.text = @"artist";
    albumLabel.text = @"album";
    
    titleLabel.alpha = .5;
    artistLabel.alpha = .5;
    albumLabel.alpha = .5;
    
    [parentView addSubview:titleLabel];
    [parentView addSubview:artistLabel];
    [parentView addSubview:albumLabel];
    
    popup = [nnMediaPickerPopUp initWithID:101];
//    if (!self.adsRemoved) {
//        popup.hasAds = YES;
//    }
    popup.delegate = self;
    
    CGFloat waveY = albumLabel.frame.origin.y + albumLabel.frame.size.height + (waveViewHeight/3);
    placeholder = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, waveY) fontSize:24 text:@"Select a song from the menu"];
    [parentView addSubview:placeholder];
    
    //[self filePicked:popup row:0];
    [self showPickerPopup:nil];
    
    upperView = [[PassThroughView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:parentView];
    [self.view addSubview:upperView];
    
//    if (!self.adsRemoved) {
//        [self addAds];
//        [self createAndLoadInterstitial];
//    }
    
    [self createTransport];
    [self createAppTour];
}

- (void)createAppTour {
    NSArray *theme = [nnKit handleColorsForSimplyMusic:1];
    CGFloat fontSize = SW()/15;
    
    menuHelp = [nnKit makeLabelWithCenter:menuButton.center fontSize:fontSize text:@" Menu "];
    //menuHelp.backgroundColor = [theme objectAtIndex:0];
    menuHelp.textColor = [theme objectAtIndex:1];
    menuHelp.layer.cornerRadius = 8;
    menuHelp.layer.masksToBounds = YES;
    
    homeHelp = [nnKit makeLabelWithCenter:homeButton.center fontSize:fontSize text:@" Home "];
    //homeHelp.backgroundColor = [theme objectAtIndex:0];
    homeHelp.textColor = [theme objectAtIndex:1];
    homeHelp.layer.cornerRadius = 8;
    homeHelp.layer.masksToBounds = YES;
    
    questionHelp = [nnKit makeLabelWithCenter:questionButton.center fontSize:fontSize text:@" Help "];
    //questionHelp.backgroundColor = [theme objectAtIndex:0];
    questionHelp.textColor = [theme objectAtIndex:1];
    questionHelp.layer.cornerRadius = 8;
    questionHelp.layer.masksToBounds = YES;
    
    metaHelp = [nnKit makeLabelWithCenter:artistLabel.center fontSize:fontSize text:@" Track Info "];
    //metaHelp.backgroundColor = [theme objectAtIndex:0];
    metaHelp.textColor = [theme objectAtIndex:1];
    metaHelp.layer.cornerRadius = 8;
    metaHelp.layer.masksToBounds = YES;
    
    CGFloat waveY = albumLabel.frame.origin.y + albumLabel.frame.size.height + (waveViewHeight/3);
    waveHelp = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, waveY) fontSize:fontSize text:@" Tap/Drag to FF/RW "];
    //waveHelp.backgroundColor = [theme objectAtIndex:0];
    waveHelp.textColor = [theme objectAtIndex:1];
    waveHelp.layer.cornerRadius = 8;
    waveHelp.layer.masksToBounds = YES;
    
    transportHelp = [nnKit makeLabelWithCenter:playButton.center fontSize:fontSize text:@" Play/Pause, skip tracks "];
    //transportHelp.backgroundColor = [theme objectAtIndex:0];
    transportHelp.textColor = [theme objectAtIndex:1];
    transportHelp.layer.cornerRadius = 8;
    transportHelp.layer.masksToBounds = YES;

    loopHelp = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, loopToggle.center.y) fontSize:fontSize text:@" Toggle Shuffle and/or Loop "];
    //loopHelp.backgroundColor = [theme objectAtIndex:0];
    loopHelp.textColor = [theme objectAtIndex:1];
    loopHelp.layer.cornerRadius = 8;
    loopHelp.layer.masksToBounds = YES;
    
    if (self.adsRemoved) {
        CGPoint center = CGPointMake(menuHelp.center.x, menuHelp.center.y+menuHelp.frame.size.height);
        menuHelp2 = [nnKit makeLabelWithCenter:center fontSize:fontSize/2 text:@" Menu controls: "];
        //menuHelp2.backgroundColor = [theme objectAtIndex:0];
        menuHelp2.textColor = [theme objectAtIndex:1];
        menuHelp2.layer.cornerRadius = 8;
        menuHelp2.layer.masksToBounds = YES;
        
        center = CGPointMake(menuHelp.center.x, menuHelp2.center.y+menuHelp2.frame.size.height);
        menuHelp3 = [nnKit makeLabelWithCenter:center fontSize:fontSize/2 text:@" Long press to reorder "];
        //menuHelp3.backgroundColor = [theme objectAtIndex:0];
        menuHelp3.textColor = [theme objectAtIndex:1];
        menuHelp3.layer.cornerRadius = 8;
        menuHelp3.layer.masksToBounds = YES;
        
        center = CGPointMake(menuHelp.center.x, menuHelp3.center.y+menuHelp3.frame.size.height);
        menuHelp4 = [nnKit makeLabelWithCenter:center fontSize:fontSize/2 text:@" Swipe to delete "];
        //menuHelp3.backgroundColor = [theme objectAtIndex:0];
        menuHelp4.textColor = [theme objectAtIndex:1];
        menuHelp4.layer.cornerRadius = 8;
        menuHelp4.layer.masksToBounds = YES;
        
        center = CGPointMake(volSlider.center.x, volSlider.frame.origin.y+3);
        volumeHelp = [nnKit makeLabelWithCenter:center fontSize:fontSize text:@" Volume "];
        //volumeHelp.backgroundColor = [theme objectAtIndex:0];
        volumeHelp.textColor = [theme objectAtIndex:1];
        volumeHelp.layer.cornerRadius = 8;
        volumeHelp.layer.masksToBounds = YES;
        
        center = CGPointMake(volumeHelp.center.x, volumeHelp.center.y+volumeHelp.frame.size.height);
        volumeHelp2 = [nnKit makeLabelWithCenter:center fontSize:fontSize/2 text:@" Double tap to reset "];
        //volumeHelp.backgroundColor = [theme objectAtIndex:0];
        volumeHelp2.textColor = [theme objectAtIndex:1];
        volumeHelp2.layer.cornerRadius = 8;
        volumeHelp2.layer.masksToBounds = YES;
    }
}

- (void)createTransport {
    CGFloat topRowY = 3;
    CGFloat yOffset = (SH()-iAdHeight)-(SW()/topRowY);
    CGFloat toggleSize = SW()/11;
    CGFloat buffer = toggleSize/3;
    CGFloat imageSize = .75;
    
    NSArray *theme = [nnKit handleColorsForSimplyMusic:themeID];
    shuffleToggle = [[NNToggle alloc] initWithFrame:CGRectMake(0, 0, toggleSize, toggleSize)];
    shuffleToggle.center = CGPointMake(SW()/3, yOffset);
    shuffleToggle.tag = 0;
    shuffleToggle.borderWidth = 0;
    shuffleToggle.cornerRadius = 3;
    shuffleToggle.offColor = [theme objectAtIndex:2];
    shuffleToggle.onColor = [theme objectAtIndex:4];
    shuffleToggle.image = [UIImage imageNamed:@"shuffle.pdf"];
    shuffleToggle.imageSize = imageSize;
    shuffleToggle.delegate = self;
    
    loopToggle = [[NNToggle alloc] initWithFrame:CGRectMake(0, 0, toggleSize, toggleSize)];
    loopToggle.center = CGPointMake((SW()/3)*2, yOffset);
    loopToggle.tag = 1;
    loopToggle.borderWidth = 0;
    loopToggle.cornerRadius = 3;
    loopToggle.offColor = [theme objectAtIndex:2];
    loopToggle.onColor = [theme objectAtIndex:4];
    loopToggle.image = [UIImage imageNamed:@"loop.pdf"];
    loopToggle.imageSize = imageSize;
    loopToggle.delegate = self;
    
    //CGFloat toggleY = ffButton.frame.origin.y+ffButton.frame.size.height+toggleSize+buffer;
    CGFloat toggleY = shuffleToggle.frame.origin.y+shuffleToggle.frame.size.height+toggleSize+buffer;
    
    playButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"play.pdf"] frame:CGRectMake(0, 0, SW()/4, SW()/4) method:@"handlePlay:" fromClass:self];
    //playButton.center = CGPointMake(SW()/2, yOffset);
    playButton.center = CGPointMake(SW()/2, toggleY);
    
    ffButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"ff.pdf"] frame:CGRectMake(0, 0, SW()/5, SW()/5) method:@"handleFF:" fromClass:self];
    ffButton.tag = 0;
    //ffButton.center = CGPointMake(SW()-(SW()/5), yOffset);
    ffButton.center = CGPointMake(SW()-(SW()/5), toggleY);
    
    rwButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"rw.pdf"] frame:CGRectMake(0, 0, SW()/5, SW()/5) method:@"handleFF:" fromClass:self];
    rwButton.tag = 1;
    //rwButton.center = CGPointMake(SW()/5, yOffset);
    rwButton.center = CGPointMake(SW()/5, toggleY);
    
    if (self.adsRemoved) {
        [self makeVolSlider:YES];
    }
}

- (void)dtSlider:(UITapGestureRecognizer*)sender {
    [volSlider removeFromSuperview];
    volSlider = nil;
    [self makeVolSlider:NO];
    [self sliderAction:volSlider];
    //NSLog(@"%f",volSlider.value);
}

- (void)makeVolSlider:(BOOL)animate {
    CGFloat volHeight = SH()/19;

    volSlider = [[NNSlider alloc] initWithFrame:CGRectMake(0, SH()-volHeight, SW()-100, volHeight)];
    volSlider.center = CGPointMake(SW()/2, volSlider.center.y);
    volSlider.valueScale = 2;
    volSlider.value = 1;
    volSlider.shouldDoCoolAnimation = animate;
    //        volSlider.lineColor = [theme objectAtIndex:1];
    //        volSlider.knobColor = [theme objectAtIndex:2];
    [volSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dtSlider:)];
    t.numberOfTapsRequired = 2;
    
    [volSlider addGestureRecognizer:t];
    
    if (!animate) {
        [upperView addSubview:volSlider];
    }
}

- (void)addTransport {
    [nnKit animateViewGrowAndShow:shuffleToggle or:nil completion:nil];
    [nnKit animateViewGrowAndShow:loopToggle or:nil completion:nil];
    [nnKit animateViewGrowAndShow:playButton or:nil completion:nil];
    [nnKit animateViewGrowAndShow:ffButton or:nil completion:nil];
    [nnKit animateViewGrowAndShow:rwButton or:nil completion:nil];
    
    [parentView addSubview:shuffleToggle];
    [parentView addSubview:loopToggle];
    [parentView addSubview:playButton];
    [parentView addSubview:ffButton];
    [parentView addSubview:rwButton];
    
    if (self.adsRemoved) {
        [upperView addSubview:volSlider];
    }
    
    hasTransport = YES;
}

- (void)sliderAction:(NNSlider*)sender {
    vol = sender.value;
    
    if (waveView) {
        waveView.player.volume = sender.value;
    }
}

- (void)handleQuestion:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    if (!hasHelp) {
        hasHelp = YES;
        
        [self openHelp];
        
        //timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(handleTimer) userInfo:nil repeats:NO];
    }
//    else {
//        //[self handleTimer];
//    }
}

//- (void)handleTimer {
//    [timer invalidate];
//    timer = nil;
//    
//    if (hasHelp) {
//        hasHelp = NO;
//        [self closeHelp];
//    }
//    
//}
- (void)openHelp {
//    closeView = [[UIView alloc] initWithFrame:self.view.frame];
//    UITapGestureRecognizer *tapCloseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTimer)];
//    [closeView addGestureRecognizer:tapCloseView];
//    [nnKit addBlurToView:closeView isDark:YES withAlpha:.9];
//    [nnKit animateViewGrowAndShow:closeView or:nil completion:^(BOOL done){
//        
//    }];
    [nnKit addCloseViewTo:upperView withAlpha:.9 withCloseMethod:@"closeHelp" fromClass:self];
    
    if (waveView) {
        waveHelp.center = waveView.center;
    }
    
    [nnKit animateViewGrowAndShow:menuHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:homeHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:questionHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:metaHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:waveHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:transportHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:loopHelp or:nil completion:nil];

    //[upperView addSubview:closeView];
    [upperView addSubview:menuHelp];
    [upperView addSubview:homeHelp];
    [upperView addSubview:questionHelp];
    [upperView addSubview:metaHelp];
    [upperView addSubview:waveHelp];
    [upperView addSubview:transportHelp];
    [upperView addSubview:loopHelp];
    
    if (self.adsRemoved) {
        [nnKit animateViewGrowAndShow:menuHelp2 or:nil completion:nil];
        [nnKit animateViewGrowAndShow:menuHelp3 or:nil completion:nil];
        [nnKit animateViewGrowAndShow:menuHelp4 or:nil completion:nil];
        [nnKit animateViewGrowAndShow:volumeHelp or:nil completion:nil];
        [nnKit animateViewGrowAndShow:volumeHelp2 or:nil completion:nil];
        [upperView addSubview:volumeHelp];
        [upperView addSubview:volumeHelp2];
        [upperView addSubview:menuHelp2];
        [upperView addSubview:menuHelp3];
        [upperView addSubview:menuHelp4];
    }
}
- (void)closeHelp {
//    [nnKit animateViewShrinkAndWink:closeView or:nil andRemoveFromSuperview:YES completion:nil];
//    closeView = nil;
    hasHelp = NO;
    [nnKit dismissCloseViewFrom:upperView];
    
    [nnKit animateViewShrinkAndWink:menuHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:homeHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:questionHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:metaHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:waveHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:transportHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:loopHelp or:nil andRemoveFromSuperview:YES completion:nil];
    
    if (self.adsRemoved) {
        [nnKit animateViewShrinkAndWink:volumeHelp or:nil andRemoveFromSuperview:YES completion:nil];
        [nnKit animateViewShrinkAndWink:volumeHelp2 or:nil andRemoveFromSuperview:YES completion:nil];
        [nnKit animateViewShrinkAndWink:menuHelp2 or:nil andRemoveFromSuperview:YES completion:nil];
        [nnKit animateViewShrinkAndWink:menuHelp3 or:nil andRemoveFromSuperview:YES completion:nil];
        [nnKit animateViewShrinkAndWink:menuHelp4 or:nil andRemoveFromSuperview:YES completion:nil];
    }
}

- (void)handleFF:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    
    if (playing) {
        [waveView stop];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleSpinner];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            int tempSong;
            switch (sender.tag) {
                case 0:
                    lastSong = currentSong;
                    if (shuffles) {
                        [self handleShuffle];
                    } else {
                        currentSong++;
                        [self setCurrentSong:currentSong];
                    }
                    break;
                case 1:
                    tempSong = lastSong;
                    lastSong = currentSong;
                    if (shuffles) {
                        currentSong = tempSong;
                        [self setCurrentSong:currentSong];
                    } else {
                        currentSong--;
                        [self setCurrentSong:currentSong];
                        if (currentSong < 0) {
                            currentSong = (int)[popup.tableData count] - 1;
                            [self setCurrentSong:currentSong];
                        }
                    }
                    break;
                    
                default:
                    break;
            }
            
            currentSong = currentSong % [popup.tableData count];
            [self setCurrentSong:currentSong];
            NSString *stringURL = [popup fileURL:currentSong];
            NSURL *url = [self getURL:stringURL];
            [self getMetaData:url];
            [self drawWaveform:url];
            
            if (playing) {
                [waveView play];
            }
            
            [self handleSpinner];
            //[self countSongs];
        });
    });
}

- (void)handleShuffle {
    int tempSong = currentSong;
    BOOL exists = NO;
    currentSong = arc4random() % [popup.tableData count];
    [self setCurrentSong:currentSong];
    
    if ([shuffleArray count] == [popup.tableData count]) {
        shuffleArray = nil;
        shuffleArray = [[NSMutableArray alloc] init];
    }
    
    for (NSNumber *n in shuffleArray) {
        if ([NSNumber numberWithInt:currentSong] == n) {
            exists = YES;
        }
    }
    
    if (exists) {
        [self handleShuffle];
    } else {
        if (currentSong == tempSong) {
            [self handleShuffle];
        } else {
            [shuffleArray addObject:[NSNumber numberWithInt:currentSong]];
        }
    }
}

- (void)handlePlay:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    
    if (waveView) {
        if (!waveView.player.isPlaying) {
            playing = YES;
            [waveView play];
            [sender setBackgroundImage:[UIImage imageNamed:@"pause.pdf"] forState:UIControlStateNormal];
            [nnKit animatePulse:sender.layer];
            
            if (vol < .11) {
                [nnKit animateViewJiggle:volSlider];
            }
        } else {
            playing = NO;
            [waveView pause];
            [sender setBackgroundImage:[UIImage imageNamed:@"play.pdf"] forState:UIControlStateNormal];
            [sender.layer removeAllAnimations];
        }
    }
}

- (void)showPickerPopup:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    //NSLog(@"show popup");
    dispatch_async(dispatch_get_main_queue(), ^{
        //[self handleSpinner:1];
        
        closeView = [[UIView alloc] initWithFrame:self.view.frame];
        UITapGestureRecognizer *tapCloseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePopup:)];
        [closeView addGestureRecognizer:tapCloseView];
        [nnKit addBlurToView:closeView isDark:YES withAlpha:1];
        [nnKit animateViewGrowAndShow:closeView or:nil completion:^(BOOL done){
            
        }];
        
        popupView = [[UIView alloc] initWithFrame:self.view.bounds];
        [popupView setBackgroundColor:[UIColor clearColor]];
        [popupView setUserInteractionEnabled:YES];
        [popupView addSubview:closeView];
        
        [popup showFromView:popupView animated:YES];
        [popupView addSubview:popup];
        
        [upperView addSubview:popupView];
        //[parentView setUserInteractionEnabled:NO];
    });
}

- (void)goBack:(UIButton*)button {
    [nnKit animateViewJiggle:button];
    [self dismissViewControllerAnimated:YES completion:^(){
        [waveView stop];
    }];
}

#pragma mark - nnSongPicker delegates
- (void)mediaLibraryPicked:(nnMediaPickerPopUp *)thispopup {
    //NSLog(@"media library picked");
}
- (void)songPickerDidFinish:(nnMediaPickerPopUp *)thispopup {
    //NSLog(@"song picker did finish");
//    if (placeholder) {
//        [placeholder removeFromSuperview];
//        placeholder = nil;
//    }
//    [popup hideWithAnimated:YES];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self handleSpinner];
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self drawWaveform:thispopup.picker.song.assetURL];
//            
//            if (!playButton) {
//                [self createTransport];
//            }
//            
//            [self handleSpinner];
//        });
//    });
}

- (void)songPickerDidCancel:(nnMediaPickerPopUp *)thispopup {
    //NSLog(@"song picker did cancel");
}

- (void)filePicked:(nnMediaPickerPopUp *)thispopup row:(int)row {
    BOOL currentlyPlaying = NO;
    if (waveView.player.isPlaying) {
        currentlyPlaying = YES;
    }
    
    if (placeholder) {
        [placeholder removeFromSuperview];
        placeholder = nil;
        
        [menuButton.layer removeAllAnimations];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleSpinner];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            lastSong = currentSong;
            [self setCurrentSong:row];
            NSURL *url = [self getURL:popup.currentFileURL];
            [self getMetaData:url];
            [self drawWaveform:url];
            
            if (!hasTransport) {
                [self addTransport];
            }
            
            [self handleSpinner];
            
            if (currentlyPlaying) {
                [self handlePlay:playButton];
            }
        });
    });
}

- (void)setCurrentSong:(int)song {
    currentSong = song;
    popup.currentlyPlaying = currentSong;
}

- (NSURL*)getURL:(NSString*)strURL {

    NSString * unescapedQuery = [[NSString alloc] initWithFormat:@"%@", strURL];
    NSString * escapedQuery = [unescapedQuery stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSString * urlString = [[NSString alloc] initWithFormat:@"file://%@", escapedQuery];
    NSURL* url = [NSURL URLWithString:urlString];

    return  url;
}

- (void)getMetaData:(NSURL*)url {
    dispatch_async(dispatch_get_main_queue(), ^{
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        NSString *title;
        NSString *artist;
        NSString *album;
        for (NSString *format in [asset availableMetadataFormats]) {
            for (AVMetadataItem *item in [asset metadataForFormat:format]) {
                if ([[item commonKey] isEqualToString:@"title"]) {
                    title = (NSString*)[item value];
                }
                
                if ([[item commonKey] isEqualToString:@"artist"]) {
                    artist = (NSString*)[item value];
                }
                
                if ([[item commonKey] isEqualToString:@"albumName"]) {
                    album = (NSString*)[item value];
                }
            }
        }
        
        titleLabel.alpha = 1;
        if (title) {
            titleLabel.text = title;
        } else {
            titleLabel.text = [NSString stringWithFormat:@"%@",[popup.tableData objectAtIndex:currentSong]];
        }
        if (artist) {
            artistLabel.text = artist;
            artistLabel.alpha = 1;
        } else {
            artistLabel.text = @" ";
        }
        if (album) {
            albumLabel.text = album;
            albumLabel.alpha = 1;
        } else {
            albumLabel.text = @" ";
        }
    });
}

- (void)drawWaveform:(NSURL*)url {
    if (waveView) {
        if (waveView.player.isPlaying) {
            [waveView stop];
            [playButton setBackgroundImage:[UIImage imageNamed:@"play.pdf"] forState:UIControlStateNormal];
            [playButton.layer removeAllAnimations];
        }
        
        [waveView removeFromSuperview];
        waveView = nil;
    }
    
    NSArray *theme = [nnKit handleColorsForSimplyMusic:themeID];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    UIColor *normalColor = [theme objectAtIndex:1];
    UIColor *fillColor = [theme objectAtIndex:3];
    
    CGFloat waveY = albumLabel.frame.origin.y + albumLabel.frame.size.height + 10;
    waveView = [[nnWaveformPlayerView alloc] initWithFrame:CGRectMake(0, 0, SW()-80, waveViewHeight) asset:asset color:normalColor progressColor:fillColor];
    waveView.center = CGPointMake(SW()/2, waveY); //(SH()-iAdHeight)/2);
    waveView.player.volume = vol;
    waveView.delegate = self;
    
    //waveView.tag = 1;
    //waveView.player.volume = 1;
    //[waveView.player setEnableRate:YES];
    //[waveView.player setRate:1];
    //waveView.loops = NO;

    waveView.center = parentView.center;
    [parentView addSubview:waveView];
    [nnKit animateViewGrowAndShow:waveView or:nil completion:nil];
    [waveView.player prepareToPlay];
}

#pragma mark - nnMediaPickerPopup delegate

- (void)popupDidCancel:(nnMediaPickerPopUp *)popup {
    //NSLog(@"popup did cancel");
}
- (void)popupDidHide:(nnMediaPickerPopUp *)popup {
    //NSLog(@"popup did hide");
    
    [self globalCloseActions];
}
- (void)closePopup:(UITapGestureRecognizer*)sender {
    [popup hideWithAnimated:YES];
}

- (void)globalCloseActions {
    [popupView setUserInteractionEnabled:NO];
    [nnKit animateViewShrinkAndWink:closeView or:nil andRemoveFromSuperview:NO completion:^(BOOL done){
        [closeView removeFromSuperview];
        [popupView removeFromSuperview];
        popupView = nil;
        closeView = nil;
        [parentView setUserInteractionEnabled:YES];
    }];
    
    if (placeholder) {
        [nnKit animatePulse:menuButton.layer];
    }
}

- (void)cellMoved:(nnMediaPickerPopUp *)popup fromIndex:(int)from toIndex:(int)to {
    if (waveView) {
        if (from == currentSong) {
            [self setCurrentSong:to];
        } else {
            if (from > currentSong) {
                if (to <= currentSong) {
                    currentSong++;
                    [self setCurrentSong:currentSong];
                }
            } else {
                if (to >= currentSong) {
                    currentSong--;
                    [self setCurrentSong:currentSong];
                }
            }
        }
        
        if (lastSong) {
            if (from == lastSong) {
                lastSong = to;
            } else {
                if (from > lastSong) {
                    if (to <= lastSong) {
                        lastSong++;
                    }
                } else {
                    if (to >= lastSong) {
                        lastSong--;
                    }
                }
            }
        }
    }
}

#pragma mark - nnWaveformPlayerView delegate and other methods

- (void)progressDidChange:(nnWaveformPlayerView *)player {
}

- (void)didReceiveTouch:(UIGestureRecognizer *)sender {
}

- (void)didStartPlaying:(nnWaveformPlayerView *)player {
}

- (void)didPausePlaying:(nnWaveformPlayerView *)player {
}

- (void)didStopPlaying:(nnWaveformPlayerView *)player {
}

- (void)playerDidFinish:(nnWaveformPlayerView *)player successfully:(BOOL)flag {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self handleSpinner];
  
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (loops) {
                [waveView play];
            } else {
                lastSong = currentSong;
                
                if (shuffles) {
                    [self handleShuffle];
                } else {
                    currentSong++;
                    [self setCurrentSong:currentSong];
                }
                currentSong = currentSong % [popup.tableData count];
                [self setCurrentSong:currentSong];
                NSString *stringURL = [popup fileURL:currentSong];
                NSURL *url = [self getURL:stringURL];
                [self getMetaData:url];
                [self drawWaveform:url];
                [waveView play];
            }
            
            [self handleSpinner];
            //[self countSongs];
        });
    });
}

#pragma mark - Activity Indicator

- (void)handleSpinner {
    if (!spinner) {
        [parentView setUserInteractionEnabled:NO];
        
        int num = RAND(12);
        colorTheme = [nnKit colorTheme:num];
        
        spinner = [[MONActivityIndicatorView alloc] init];
        spinner.alpha = 0;
        spinner.delegate = self;
        spinner.numberOfCircles = 5;
        spinner.radius = SW()/16;
        spinner.internalSpacing = 3;
        
        CGFloat width = (spinner.numberOfCircles * ((2 * spinner.radius) + spinner.internalSpacing)) - spinner.internalSpacing;
        CGFloat height = spinner.radius * 2;
        
        if (waveView) {
            [spinner setCenter:CGPointMake(waveView.center.x-(width/2), waveView.center.y-(height/2))];
        } else {
            [spinner setCenter:CGPointMake(parentView.center.x-(width/2), parentView.center.y-(height/2))];
        }
        
        [parentView addSubview:spinner];
        [spinner startAnimating];
        
        [UIView animateWithDuration:.4
                              delay:.2
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             [spinner setAlpha:1];
         } completion:nil];
        
    } else {
        [UIView animateWithDuration:.4/2
                              delay:0
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^
         {
             spinner.alpha = 0;
         } completion:^(BOOL finished){
             if (finished) {
                 [spinner stopAnimating];
                 [spinner removeFromSuperview];
                 colorTheme = nil;
                 spinner = nil;
                 
                 [parentView setUserInteractionEnabled:YES];
             }
         }];
    }
}

#pragma mark - NNToggle delegate

- (void)toggleDidSwitchState:(NNToggle*)toggle {
    switch (toggle.tag) {
        case 0:
            shuffles = toggle.isOn;
            
            if (toggle.isOn) {
                [shuffleArray addObject:[NSNumber numberWithInt:currentSong]];
            } else {
                shuffleArray = nil;
                shuffleArray = [[NSMutableArray alloc] init];
            }
            break;
        case 1:
            loops = toggle.isOn;
            break;
            
        default:
            break;
    }
}

- (void)toggleWasTapped:(NNToggle*)toggle {
    
}

#pragma mark - MONActivityIndicatorView delegate

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    UIColor *color = [colorTheme objectAtIndex:index%5];
    
    return color;
}

//#pragma Ads
//
//- (void)countSongs {
//    songCount = songCount + 1;
//    songCount = songCount % 4;
//    if (songCount == 0 ) {
//        if ([interstitial isReady]) {
//            if (playing) {
//                [self handlePlay:playButton];
//            }
//            [interstitial presentFromRootViewController:self];
//        }
//    }
//}
//
//- (void)createAndLoadInterstitial {
//    interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-8086035338872648/5079464817"];
//    interstitial.delegate = self;
//    
//    GADRequest *request = [self getGADRequest];
//    
//    [interstitial loadRequest:request];
//}
//
//- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
//    [self createAndLoadInterstitial];
//}
//
//- (void)addAds {
//    bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
//    bannerView.frame = CGRectMake(0, SH(), bannerView.frame.size.width, bannerView.frame.size.height);
//    bannerView.adUnitID = @"ca-app-pub-8086035338872648/9208613213";
//    bannerView.rootViewController = self;
//    bannerView.delegate = self;
//    
//    bannerIsVisible = NO;
//    
//    GADRequest *request = [self getGADRequest];
//
//    [self.view addSubview:bannerView];
//    [bannerView loadRequest:request];
//}
//
//- (GADRequest*)getGADRequest {
//    GADRequest *request = [GADRequest request];
//    if (testAds) {
//        request.testDevices = @[@"bec0bbadab101b4ce67c4c885d45d9de"];
//    }
//    return request;
//}
//
//- (void)adViewDidReceiveAd:(GADBannerView *)banner {
//    if (!bannerIsVisible)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
//            banner.frame = CGRectOffset(bannerView.frame, 0, -iAdHeight);
//            [UIView commitAnimations];
//            bannerIsVisible = YES;
//        });
//    }
//}
//
//- (void)adView:(GADBannerView *)banner didFailToReceiveAdWithError:(GADRequestError *)error {
//    NSLog(@"adView:didFailToReceiveAdWithError: %@", error.localizedDescription);
//    if (bannerIsVisible)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
//            bannerView.frame = CGRectOffset(bannerView.frame, 0, iAdHeight);
//            [UIView commitAnimations];
//            bannerIsVisible = NO;
//        });
//    }
//}
//
//- (void)adViewWillPresentScreen:(GADBannerView *)banner {
//    if (playing) {
//        [self handlePlay:playButton];
//    }
//}

@end
