//
//  InfoViewController.m
//
//  Created by Cady Holmes on 12/28/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "InfoViewController.h"
#import "nnKit.h"

@interface InfoViewController ()

@end

@implementation InfoViewController
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    int themeIndex = 1;
    NSArray *theme = [nnKit handleColorsForSimplyMusic:themeIndex];
    self.view.backgroundColor = [theme objectAtIndex:1];
    UIColor *textColor = [theme objectAtIndex:0];
    
    CGFloat fontSize1 = SW()/8;
    CGFloat fontSize2 = SW()/12;
    CGFloat fontSize3 = SW()/16;
    
    CGFloat buffer = 30;
    
    UILabel *titleLabel = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, SH()*.15) fontSize:fontSize1 text:@"Simply Music"];
    titleLabel.textColor = textColor;
    
    CGFloat y = titleLabel.frame.origin.y + titleLabel.frame.size.height + buffer;
    UILabel *nnLabel = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, y) fontSize:fontSize2 text:@"by notnatural"];
    nnLabel.textColor = textColor;
    
    y = nnLabel.frame.origin.y + nnLabel.frame.size.height + (buffer*2);
    UILabel *creditLabel = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, y) fontSize:fontSize3 text:@"Design and Development by:"];
    creditLabel.textColor = textColor;
    
    y = creditLabel.frame.origin.y + creditLabel.frame.size.height + (buffer*2);
    UIButton *urlButton = [nnKit makeButtonWithCenter:CGPointMake(SW()/2, y) fontSize:fontSize3 title:@"notnatural.co" method:@"openURL:" fromClass:self];
    
//    UILabel *urlLabel = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, y) fontSize:fontSize2 text:@"danny.notnatural.co"];
//    urlLabel.textColor = textColor;
//    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openURL:)];
//    [urlLabel addGestureRecognizer:t];
//    [urlLabel setUserInteractionEnabled:YES];
    
    [self.view addSubview:titleLabel];
    [self.view addSubview:nnLabel];
    [self.view addSubview:creditLabel];
    [self.view addSubview:urlButton];
    
    CGFloat buttonSize = 60;
    UIButton *button = [nnKit makeButtonWithImage:[UIImage imageNamed:@"home.pdf"] frame:CGRectMake(0, self.view.frame.size.height-75, buttonSize, buttonSize) method:@"goBack:" fromClass:self];
    [button setCenter:CGPointMake(self.view.frame.size.width/2, button.center.y)];
    [self.view addSubview:button];
}

- (void)openURL:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://notnatural.co"]];
}

- (void)goBack:(UIButton*)button {
    [nnKit animateViewBigJiggleAlt:button];
    [self dismissViewControllerAnimated:YES completion:^(){
    }];
}

@end
