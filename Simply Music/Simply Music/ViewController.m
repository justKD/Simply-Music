//
//  ViewController.m
//
//  Created by Cady Holmes on 12/16/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "nnKit.h"
#import "PlayerViewController.h"
#import "WebUploadViewController.h"
#import "UIColor+NNColors.h"
#import "MONActivityIndicatorView.h"
#import "InfoViewController.h"
#import <StoreKit/StoreKit.h>
#import "kdPrimitiveDataStore.h"

@interface ViewController () <MONActivityIndicatorViewDelegate>
{
    int themeID;
    NSArray *theme;
    
    UILabel *playHelp;
    UILabel *uploadHelp;
    UILabel *nnLabel;
    UILabel *title;
    UIImageView *logo;
    UIImageView *icon;
//    UIButton *proButton;
    BOOL hasHelp;
    BOOL adsRemoved;
    //NSTimer *timer;
    
    UIView *closeView;
    
    MONActivityIndicatorView *spinner;
    NSArray* colorTheme;
    
    kdPrimitiveDataStore *globalSettings;
//    UIView *proPopup;
}

@end

@implementation ViewController

#define kRemoveAdsProductIdentifier @"co.notnatural.simplymusic.promode"

// temp
//- (void)deletePlist {
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
//    path = [path stringByAppendingPathComponent:@"MainPlaylist.plist"];
//    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path]) {
//        
//        [fileManager removeItemAtPath:path error:nil];
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    adsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:@"adsRemoved"];
//    [[NSUserDefaults standardUserDefaults] synchronize];

    adsRemoved = YES;
    
    themeID = 1;
    theme = [nnKit handleColorsForSimplyMusic:themeID];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //[self createSplash];
    [self createUI];
    
    [self handleOpenCount];
}

- (void)handleOpenCount {
    if (!globalSettings.data) {
        int openCount = 1;
        [globalSettings save:@[[NSNumber numberWithInt:openCount]]];
    } else {
        int openCount = [[globalSettings.data lastObject] intValue];
        openCount++;
        openCount = openCount % 10;
        openCount = MAX(openCount, 1);
        
        [globalSettings save:@[[NSNumber numberWithInt:openCount]]];
        
        if (openCount == 3) {
            [SKStoreReviewController requestReview];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
//    if (!adsRemoved) {
//        if (proButton) {
//            [nnKit animatePulse:proButton.layer shrinkTo:.75 withDuration:.8];
//        }
//    }
}

//- (void)createSplash {
//    self.view.backgroundColor = [theme objectAtIndex:0];
//    
//    icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headphone.pdf"]];
//    icon.frame = self.view.frame;
//    icon.contentMode = UIViewContentModeScaleAspectFit;
//    
//    CGFloat fontSize1 = SW()/8;
////    CGFloat fontSize2 = SW()/12;
//    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SW(), fontSize1+10)];
//    title.font = [UIFont fontWithName:[nnKit getGlobalFont] size:fontSize1];
//    title.text = @"Simply Music";
//    title.center = CGPointMake(SW()/2, SH()/5);
//    title.textAlignment = NSTextAlignmentCenter;
//    title.textColor = [theme objectAtIndex:1];
//    
//    [nnKit animateViewGrowAndShow:nil or:icon completion:nil];
//    [self.view addSubview:icon];
//    [nnKit animateViewGrowAndShow:title or:nil completion:nil];
//    [self.view addSubview:title];
//
//    [self animateNNLogo];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self handleSpinner];
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [nnKit animateViewAlpha:icon to:0];
//            [nnKit animateViewAlpha:title to:0];
//            [nnKit animateViewAlpha:nnLabel to:0];
//            [nnKit animateViewAlpha:logo to:0];
//            [self handleSpinner];
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [icon removeFromSuperview];
//                [title removeFromSuperview];
//                [nnLabel removeFromSuperview];
//                [logo removeFromSuperview];
//                icon = nil;
//                title = nil;
//                nnLabel = nil;
//                logo = nil;
//                [self createUI];
//            });
//        });
//    });
//}

- (void)animateNNLogo
{
    logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"small logo.pdf"]];
    logo.frame = CGRectMake(0, 0, 70, 70);
    logo.center = CGPointMake(SW()/2, SH()*.75);
    
    if (![nnKit isIPhone4]) {
        nnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, logo.frame.origin.y+logo.frame.size.height, self.view.frame.size.width, 70)];
        nnLabel.textAlignment = NSTextAlignmentCenter;
        nnLabel.font = [UIFont fontWithName:nnKitGlobalFont size:self.view.frame.size.width/18];
        nnLabel.text = @"notnatural.co";
        nnLabel.textColor = [theme objectAtIndex:1];
        [self.view addSubview:nnLabel];
    }
    
    [self.view addSubview:logo];
    
    [nnKit animateViewGrowAndShow:logo or:nil completion:nil];
    [nnKit animateViewGrowAndShow:nnLabel or:nil completion:nil];
}

- (void)createUI {
    [self.view setBackgroundColor:[theme objectAtIndex:0]];
    
    CGFloat playSize = SW()/1.5;
    CGFloat uploadSize = SW()/3;
    if ([nnKit isIPhone4]) {
        playSize = SW()/2;
        uploadSize = SW()/3.5;
    }
    
    UIButton *playerButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"player.pdf"] frame:CGRectMake(0, 0, playSize, playSize) method:@"presentPlayerVC:" fromClass:self];
    playerButton.center = CGPointMake(SW()/2, SH()/2.5);
    
    UIButton *uploadButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"www.pdf"] frame:CGRectMake(0, 0, uploadSize, uploadSize) method:@"presentWebUploadVC:" fromClass:self];
    uploadButton.center = CGPointMake(SW()/2, SH()-(SH()/5));
    
    CGFloat smallButtonSize = SW()/10;
    CGFloat smallButtonMargin = 10;
    
    UIButton *questionButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"question.pdf"] frame:CGRectMake(smallButtonMargin, SH()-smallButtonSize-smallButtonMargin, smallButtonSize, smallButtonSize) method:@"handleQuestion:" fromClass:self];
    
//    UIButton *infoButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"info.pdf"] frame:CGRectMake(SW()-smallButtonMargin-smallButtonSize, SH()-smallButtonSize-smallButtonMargin, smallButtonSize, smallButtonSize) method:@"presentInfoVC:" fromClass:self];
    
    CGFloat fontSize1 = SW()/8;
//    CGFloat fontSize2 = SW()/18;
    CGFloat helpFontSize = SW()/15;
    
    playHelp = [nnKit makeLabelWithCenter:playerButton.center fontSize:helpFontSize text:@" Play your music! "];
    uploadHelp = [nnKit makeLabelWithCenter:uploadButton.center fontSize:helpFontSize text:@" Add or remove files. "];
    //playHelp.backgroundColor = [theme objectAtIndex:0];
    //uploadHelp.backgroundColor = [theme objectAtIndex:0];
    playHelp.layer.cornerRadius = 8;
    playHelp.layer.masksToBounds = YES;
    uploadHelp.layer.cornerRadius = 8;
    uploadHelp.layer.masksToBounds = YES;

    playHelp.textColor = [theme objectAtIndex:1];
    uploadHelp.textColor = [theme objectAtIndex:1];
    
    title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SW(), fontSize1+10)];
    title.font = [UIFont fontWithName:[nnKit getGlobalFont] size:fontSize1];
    title.text = @"Simply Music";
    title.center = CGPointMake(SW()/2, 70);
    title.textAlignment = NSTextAlignmentCenter;
    title.textColor = [theme objectAtIndex:1];
    
    // *********temp**********
//    UITapGestureRecognizer *t = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deletePlist)];
//    [title addGestureRecognizer:t];
//    [title setUserInteractionEnabled:YES];
    
//    nnLabel = [nnKit makeLabelWithCenter:CGPointMake(SW()/2, SH()-(fontSize2)) fontSize:fontSize2 text:@" notnatural.co "];
//    nnLabel.textColor = [theme objectAtIndex:1];
    
    [nnKit animateViewGrowAndShow:title or:nil completion:nil];
    [self.view addSubview:title];
//    [nnKit animateViewGrowAndShow:nnLabel or:nil completion:nil];
//    [self.view addSubview:nnLabel];
    [nnKit animateViewGrowAndShow:playerButton or:nil completion:nil];
    [self.view addSubview:playerButton];
    [nnKit animateViewGrowAndShow:uploadButton or:nil completion:nil];
    [self.view addSubview:uploadButton];
    [nnKit animateViewGrowAndShow:questionButton or:nil completion:nil];
    [self.view addSubview:questionButton];
//    [nnKit animateViewGrowAndShow:infoButton or:nil completion:nil];
//    [self.view addSubview:infoButton];
    
//    if (!adsRemoved) {
//        [self addProModeButton];
//    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGFloat sysVol = [[AVAudioSession sharedInstance] outputVolume];
        if (sysVol < .4) {
            [self showVolumeAlert];
        }
    });
}

//- (void)addProModeButton {
//    proButton = [nnKit makeButtonWithImage:[UIImage imageNamed:@"exclamation.pdf"] frame:CGRectMake(0, 0, SW()/5, SW()/5) method:@"tapProMode:" fromClass:self];
//    proButton.center = CGPointMake(SW()*.2, SH()*.66);
//
//    proButton.layer.shadowColor = [UIColor flatOrangeColor].CGColor;
//    proButton.layer.shadowRadius = SW()/12;
//    proButton.layer.shadowOpacity = 1;
//    proButton.layer.masksToBounds = NO;
//
//    [nnKit animatePulse:proButton.layer shrinkTo:.75 withDuration:.8];
//
//    UIImageView *prolabel = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"promode.pdf"]];
//    prolabel.frame = CGRectMake(proButton.center.x, proButton.frame.origin.y, SW()/3, SW()/3);
//    prolabel.center = CGPointMake(prolabel.center.x, proButton.center.y);
//    prolabel.userInteractionEnabled = NO;
//
//    [self.view addSubview:proButton];
//    [self.view addSubview:prolabel];
//
//}
//- (void)tapProMode:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//    [nnKit addCloseViewTo:self.view withAlpha:1 withCloseMethod:@"closeProPopup" fromClass:self];
//
//    proPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SW()*.9, SH()*.8)];
//    proPopup.center = self.view.center;
//    proPopup.layer.cornerRadius = 8;
//
//    proPopup.backgroundColor = [UIColor flatWhiteColor];
//
//    [self.view addSubview:proPopup];
//    [nnKit animateViewGrowAndShow:proPopup or:nil completion:nil];
//
//    UIFont *font = [UIFont fontWithName:nnKitGlobalFont size:[nnKit fontSize:2]];
//    UIColor *textColor = [UIColor blackColor];
//    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
//                                                                        0,
//                                                                        proPopup.frame.size.width*.8,
//                                                                        proPopup.frame.size.height*.8)];
//
//    NSString *text = [NSString stringWithFormat:@"Purchase Pro Mode!\n\n• Remove ads\n\n• Better volume control\n\n• Swipe to delete songs\n\n• Long press to reorder your playlist!"];
//    [textView setCenter:CGPointMake(VW(proPopup)/2,VH(proPopup)/2)];
//    [textView setBackgroundColor:[UIColor clearColor]];
//    [textView setTextAlignment:NSTextAlignmentCenter];
//    [textView setTextColor:textColor];
//    [textView setFont:font];
//    [textView setText:text];
//    textView.userInteractionEnabled = NO;
//
//    [proPopup addSubview:textView];
//    [self.view addSubview:proPopup];
//
//    UIButton *purchase = [nnKit makeButtonWithCenter:CGPointMake(VW(proPopup)/2, proPopup.frame.size.height*.7) fontSize:[nnKit fontSize:1] title:@"Purchase Pro Mode!" method:@"tapPurchase:" fromClass:self];
//    UIButton *restore = [nnKit makeButtonWithCenter:CGPointMake(VW(proPopup)/2, proPopup.frame.size.height*.8) fontSize:[nnKit fontSize:1]*.75 title:@"Restore Purchases" method:@"tapRestorePurchases:" fromClass:self];
//    UIButton *cancel = [nnKit makeButtonWithCenter:CGPointMake(VW(proPopup)/2, proPopup.frame.size.height*.9) fontSize:[nnKit fontSize:2] title:@"No Thanks..." method:@"tapCancel:" fromClass:self];
//
//    [proPopup addSubview:purchase];
//    [proPopup addSubview:restore];
//    [proPopup addSubview:cancel];
//
//}
//- (void)closeProPopup {
//    if (proPopup) {
//        [nnKit animateViewShrinkAndWink:proPopup or:nil andRemoveFromSuperview:YES completion:nil];
//        proPopup = nil;
//    }
//    [nnKit dismissCloseViewFrom:self.view];
//}

//- (void)tapCancel:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//    [self closeProPopup];
//}

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

- (void)handleQuestion:(UIButton*)sender {
    [nnKit animateViewJiggle:sender];
    if (!hasHelp) {
        hasHelp = YES;
        
        [self openHelp];

        //timer = [NSTimer scheduledTimerWithTimeInterval:5. target:self selector:@selector(handleTimer) userInfo:nil repeats:NO];
    } else {
        //[self handleTimer];
    }
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
    closeView = [[UIView alloc] initWithFrame:self.view.frame];
    UITapGestureRecognizer *tapCloseView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHelp)];
    [closeView addGestureRecognizer:tapCloseView];
    [nnKit addBlurToView:closeView isDark:YES withAlpha:.9];
    [nnKit animateViewGrowAndShow:closeView or:nil completion:^(BOOL done){
        
    }];
    
    [nnKit animateViewGrowAndShow:playHelp or:nil completion:nil];
    [nnKit animateViewGrowAndShow:uploadHelp or:nil completion:nil];
    
    [self.view addSubview:closeView];
    [self.view addSubview:playHelp];
    [self.view addSubview:uploadHelp];
}
- (void)closeHelp {
    [nnKit animateViewShrinkAndWink:closeView or:nil andRemoveFromSuperview:YES completion:nil];
    closeView = nil;
    
    hasHelp = NO;
    
    [nnKit animateViewShrinkAndWink:playHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [nnKit animateViewShrinkAndWink:uploadHelp or:nil andRemoveFromSuperview:YES completion:nil];
    [self.view addSubview:nnLabel];
}

- (void)presentInfoVC:(UIButton*)sender {
    [nnKit animateViewBigJiggle:sender];
    InfoViewController *vc = [[InfoViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)presentPlayerVC:(UIButton*)sender {
    [nnKit animateViewBigJiggle:sender];
    PlayerViewController *vc = [[PlayerViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.adsRemoved = adsRemoved;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)presentWebUploadVC:(UIButton*)sender{
    [nnKit animateViewBigJiggle:sender];
    WebUploadViewController *vc = [[WebUploadViewController alloc] init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - Activity Indicator

- (void)handleSpinner {
    if (!spinner) {
        [self startSpinner];
    } else {
        [self stopSpinner];
    }
}

- (void)startSpinner {
    if (spinner) {
        [self stopSpinner];
    }
    spinner = [[MONActivityIndicatorView alloc] init];
    spinner.alpha = 0;
    spinner.delegate = self;
    spinner.numberOfCircles = 5;
    spinner.radius = SW()/16;
    spinner.internalSpacing = 3;
    
    int num = RAND(12);
    if (num == 4) {
        num = 1;
    }

    colorTheme = [nnKit colorTheme:num];
    
    CGFloat width = (spinner.numberOfCircles * ((2 * spinner.radius) + spinner.internalSpacing)) - spinner.internalSpacing;
    CGFloat height = spinner.radius * 2;
    
    [spinner setCenter:CGPointMake(self.view.center.x-(width/2), SH()-height-(height/2))];
    [self.view addSubview:spinner];
    [spinner startAnimating];
    
    [UIView animateWithDuration:.4
                          delay:.2
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         [spinner setAlpha:1];
     } completion:nil];
}

- (void)stopSpinner {
    if (spinner) {
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
                 spinner = nil;
             }
         }];
    }
}

#pragma mark - MONActivityIndicatorView delegate

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView
      circleBackgroundColorAtIndex:(NSUInteger)index {
    
    UIColor *color = [colorTheme objectAtIndex:index%5];
    
    return color;
}

//# pragma Remove Ads
///* http://stackoverflow.com/questions/19556336/how-do-you-add-an-in-app-purchase-to-an-ios-application */
//
//- (void)tapRestorePurchases:(UIButton*)sender {
//    [self tapCancel:sender];
//    [self restore];
//}
//
//- (void)tapPurchase:(UIButton*)sender {
//    [nnKit animateViewJiggle:sender];
//
//    if (adsRemoved) {
//        [nnKit animateViewShrinkAndWink:proPopup or:nil andRemoveFromSuperview:YES completion:nil];
//        proPopup = nil;
//
//        proPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SW()*.6, SW()*.6)];
//        proPopup.center = self.view.center;
//        proPopup.layer.cornerRadius = 8;
//        proPopup.backgroundColor = [UIColor flatWhiteColor];
//
//        UIFont *font = [UIFont fontWithName:nnKitGlobalFont size:[nnKit fontSize:2]];
//        UIColor *textColor = [UIColor blackColor];
//        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0,
//                                                                            0,
//                                                                            proPopup.frame.size.width*.8,
//                                                                            proPopup.frame.size.height*.8)];
//
//        NSString *text = [NSString stringWithFormat:@"\n\nYou're Already Pro!\n\n\n\n( ˘ ³˘)❤"];
//        [textView setCenter:CGPointMake(VW(proPopup)/2,VH(proPopup)/2)];
//        [textView setBackgroundColor:[UIColor clearColor]];
//        [textView setTextAlignment:NSTextAlignmentCenter];
//        [textView setTextColor:textColor];
//        [textView setFont:font];
//        [textView setText:text];
//        textView.userInteractionEnabled = NO;
//
//        [proPopup addSubview:textView];
//        [self.view addSubview:proPopup];
//
//    } else {
//        [nnKit dismissCloseViewFrom:self.view];
//        [nnKit addCloseViewTo:self.view withAlpha:1 withCloseMethod:nil fromClass:self];
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self startSpinner];
//            [self removeAds];
//        });
//    }
//}
//
//- (void)cancelPurchase {
//    [self stopSpinner];
//    [nnKit dismissCloseViewFrom:self.view];
//    if (proPopup) {
//        [nnKit animateViewShrinkAndWink:proPopup or:nil andRemoveFromSuperview:YES completion:nil];
//        proPopup = nil;
//    }
//}
//
//- (void)removeAds {
//    NSLog(@"User requests to remove ads");
//
//    if([SKPaymentQueue canMakePayments]){
//        NSLog(@"User can make payments");
//
//        //If you have more than one in-app purchase, and would like
//        //to have the user purchase a different product, simply define
//        //another function and replace kRemoveAdsProductIdentifier with
//        //the identifier for the other product
//
//        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
//        productsRequest.delegate = self;
//        [productsRequest start];
//
//    }
//    else{
//        NSLog(@"User cannot make payments due to parental controls");
//        //this is called the user cannot make payments, most likely due to parental controls
//    }
//}
//
//- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
//    SKProduct *validProduct = nil;
//    int count = (int)[response.products count];
//    if(count > 0){
//        validProduct = [response.products objectAtIndex:0];
//        NSLog(@"Products Available!");
//        [self purchase:validProduct];
//    }
//    else if(!validProduct){
//        NSLog(@"No products available");
//        [self cancelPurchase];
//        //this is called if your product id is not valid, this shouldn't be called unless that happens.
//    }
//}
//
//- (void)purchase:(SKProduct *)product{
//    SKPayment *payment = [SKPayment paymentWithProduct:product];
//
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] addPayment:payment];
//}
//
//- (void)restore {
//    //this is called when the user restores purchases, you should hook this up to a button
//    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
//    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
//}
//
//- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
//{
//    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
//    for(SKPaymentTransaction *transaction in queue.transactions){
//        if(transaction.transactionState == SKPaymentTransactionStateRestored){
//            //called when the user successfully restores a purchase
//            NSLog(@"Transaction state -> Restored");
//
//            //if you have more than one in-app purchase product,
//            //you restore the correct product for the identifier.
//            //For example, you could use
//            //if(productID == kRemoveAdsProductIdentifier)
//            //to get the product identifier for the
//            //restored purchases, you can use
//            //
//            //NSString *productID = transaction.payment.productIdentifier;
//            [self doRemoveAds];
//            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//            break;
//        }
//    }
//}
//
//- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
//    for(SKPaymentTransaction *transaction in transactions){
//        switch(transaction.transactionState){
//            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
//                //called when the user is in the process of purchasing, do not add any of your own code here.
//                break;
//            case SKPaymentTransactionStatePurchased:
//                //this is called when the user has successfully purchased the package (Cha-Ching!)
//                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                NSLog(@"Transaction state -> Purchased");
//                break;
//            case SKPaymentTransactionStateRestored:
//                NSLog(@"Transaction state -> Restored");
//                [self doRemoveAds];
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//            case SKPaymentTransactionStateFailed:
//                NSLog(@"Transaction state -> Cancelled");
//                [self cancelPurchase];
//                //called when the transaction does not finish
//                if(transaction.error.code == SKErrorPaymentCancelled){
//
//                    //the user cancelled the payment ;(
//                }
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//            case SKPaymentTransactionStateDeferred:
//                NSLog(@"Transaction state -> Deferred");
//                [self doRemoveAds];
//                //add the same code as you did from SKPaymentTransactionStatePurchased here
//                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
//                break;
//        }
//    }
//}
//
//- (void)doRemoveAds {
//    adsRemoved = YES;
//    [[NSUserDefaults standardUserDefaults] setBool:adsRemoved forKey:@"adsRemoved"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    [self stopSpinner];
//}


@end
