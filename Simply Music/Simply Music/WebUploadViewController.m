//
//  WebUploadViewController.m
//
//  Created by Cady Holmes on 9/15/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "WebUploadViewController.h"
#import "GCDWebUploader.h"
#import "nnKit.h"
#import "UIColor+NNColors.h"

@interface WebUploadViewController () {
    GCDWebUploader* _webUploader;
    UILabel *ipLabel;
    
    UITextView *helpTextView;
    NSArray *theme;
    
    int themeID;
}

@end

@implementation WebUploadViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidAppear:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        _webUploader = [[GCDWebUploader alloc] initWithUploadDirectory:documentsPath];
        [_webUploader start];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
            if (_webUploader.serverURL) {
                ipLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", _webUploader.serverURL]
                                                                         attributes:underlineAttribute];
            } else {
                ipLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"No Network Detected!"]
                                                                         attributes:underlineAttribute];
            }
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    themeID = 1;
    
    theme = [nnKit handleColorsForSimplyMusic:themeID];
    UIColor *textColor = [theme objectAtIndex:1];
    [self.view setBackgroundColor:[theme objectAtIndex:0]];
    //[self.view setBackgroundColor:[UIColor flatBlackColor]];
    
    CGFloat height;
    CGFloat smallHeight;
    CGFloat buttonSize = 60;
    
    if ([nnKit isIPad]) {
        height = 80;
        smallHeight = 50;
    } else if ([nnKit isIPhone4]) {
        height = 30;
        smallHeight = 20;
        buttonSize = 40;
    } else {
        if ([nnKit isIPhone5orIPodTouch]) {
            height = 40;
        } else {
            height = 44;
        }
        smallHeight = 24;
    }
    
    float fontSize1;
    float fontSize2;
    float fontSize3;
    float fontSize4;
    
    if ([nnKit isIPad]) {
        fontSize1 = SW()/14;
        fontSize2 = SW()/16;
        fontSize3 = SW()/18;
        fontSize4 = SW()/20;
    } else {
        fontSize1 = SW()/11;
        fontSize2 = SW()/12;
        fontSize3 = SW()/14;
        fontSize4 = SW()/16;
    }

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                               height,
                                                               self.view.frame.size.width,
                                                               height)];
    
    [label setCenter:CGPointMake(self.view.frame.size.width/2, label.center.y)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setTextColor:textColor];
    [label setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize1]];
    
    NSDictionary *underlineAttribute = @{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    label.attributedText = [[NSAttributedString alloc] initWithString:@"Manage your playlist"
                                                             attributes:underlineAttribute];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                (height*1.8),
                                                                self.view.frame.size.width,
                                                                height)];
    
    [label1 setCenter:CGPointMake(self.view.frame.size.width/2, label1.center.y)];
    [label1 setTextAlignment:NSTextAlignmentCenter];
    [label1 setTextColor:textColor];
    [label1 setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize3]];
    label1.attributedText = [[NSAttributedString alloc] initWithString:@"using a desktop browser"
                                                           attributes:underlineAttribute];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
                                                                        (height*3),
                                                                        self.view.frame.size.width,
                                                                        self.view.frame.size.height/2)];
    
    [textView setCenter:CGPointMake(self.view.frame.size.width/2, textView.center.y)];
    [textView setBackgroundColor:[UIColor clearColor]];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setTextColor:textColor];
    [textView setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize4]];
    [textView setText:[NSString stringWithFormat:@"Simply Music supports a variety of common file types including .mp3, .wav, and .aif.\n\nConnect your mobile device and computer to the same network, and keep this page open while uploading or removing files."]];
    [textView setUserInteractionEnabled:NO];
    
    
    float label2Height = 4.5;
    if ([nnKit isIPhone4]) {
        label2Height = 5.5;
    }
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                (self.view.frame.size.height-(height*label2Height)),
                                                                self.view.frame.size.width,
                                                                smallHeight)];
    
    [label2 setCenter:CGPointMake(self.view.frame.size.width/2, label2.center.y)];
    [label2 setTextAlignment:NSTextAlignmentCenter];
    [label2 setTextColor:textColor];
    [label2 setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize2]];
    [label2 setText:[NSString stringWithFormat:@"Visit this address"]];
    
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                (self.view.frame.size.height-(height*(label2Height-.8))),
                                                                self.view.frame.size.width,
                                                                smallHeight)];
    
    [label3 setCenter:CGPointMake(self.view.frame.size.width/2, label3.center.y)];
    [label3 setTextAlignment:NSTextAlignmentCenter];
    [label3 setTextColor:textColor];
    [label3 setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize3]];
    [label3 setText:[NSString stringWithFormat:@"in your desktop browser:"]];
    
    ipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                (self.view.frame.size.height-(height*(label2Height-1.5))),
                                                                self.view.frame.size.width,
                                                                height)];
    
    [ipLabel setCenter:CGPointMake(self.view.frame.size.width/2, ipLabel.center.y)];
    [ipLabel setTextAlignment:NSTextAlignmentCenter];
    [ipLabel setTextColor:textColor];
    [ipLabel setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize2]];
    
//    [label setUserInteractionEnabled:NO];
//    [label1 setUserInteractionEnabled:NO];
//    [label2 setUserInteractionEnabled:NO];
//    [label3 setUserInteractionEnabled:NO];
//    [ipLabel setUserInteractionEnabled:NO];
    
    UIButton *button = [nnKit makeButtonWithImage:[UIImage imageNamed:@"home.pdf"] frame:CGRectMake(0, self.view.frame.size.height-75, buttonSize, buttonSize) method:@"goBack:" fromClass:self];
    [button setCenter:CGPointMake(self.view.frame.size.width/2, button.center.y)];
    
    CGFloat smallButtonSize = SW()/10;
    CGFloat smallButtonMargin = 10;
    
    UIButton *questionButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"question.pdf"] frame:CGRectMake(smallButtonMargin, SH()-smallButtonSize-smallButtonMargin, smallButtonSize, smallButtonSize) method:@"handleQuestion:" fromClass:self];

    [self.view addSubview:label];
    [self.view addSubview:label1];
    [self.view addSubview:textView];
    [self.view addSubview:label2];
    [self.view addSubview:label3];
    [self.view addSubview:ipLabel];
    [self.view addSubview:button];
    [self.view addSubview:questionButton];
}

- (void)handleQuestion:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    [nnKit addCloseViewTo:self.view withAlpha:1 withCloseMethod:@"closeHelp" fromClass:self];
    
    float fontSize;
    
    if ([nnKit isIPad] || [nnKit isIPhone4]) {
        fontSize = SW()/20;
    } else {
        fontSize = SW()/16;
    }
    
    helpTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SW()*.85, SH()*.8)];
    
    [helpTextView setCenter:CGPointMake(SW()/2, SH()/2)];
    [helpTextView setBackgroundColor:[UIColor clearColor]];
    [helpTextView setTextAlignment:NSTextAlignmentCenter];
    [helpTextView setTextColor:[theme objectAtIndex:1]];
    [helpTextView setFont:[UIFont fontWithName:nnKitGlobalFont size:fontSize]];
    
    [helpTextView setText:[NSString stringWithFormat:@"Supported file extensions:\n.mp3, .wav, .aif, .aiff,\n.aifc, .alac, .caf, .aac,\n.m4a, .mp4, .3gp, and .3g2.\n\nSimply Music sorts the default playlist according to the order you upload your files.\n\nOn the player screen:\n• Long press to re-order\n• Swipe to delete"]];
    
    [helpTextView setUserInteractionEnabled:NO];
    
    [nnKit animateViewGrowAndShow:helpTextView or:nil completion:nil];
    [self.view addSubview:helpTextView];
}

- (void)closeHelp {
    [nnKit dismissCloseViewFrom:self.view];
    [nnKit animateViewShrinkAndWink:helpTextView or:nil andRemoveFromSuperview:YES completion:nil];
}

- (void)goBack:(UIButton*)button {
    [nnKit animateViewBigJiggleAlt:button];
    [self dismissViewControllerAnimated:YES completion:^(){
        [_webUploader stop];
        _webUploader = nil;
        ipLabel = nil;
    }];
}

@end
