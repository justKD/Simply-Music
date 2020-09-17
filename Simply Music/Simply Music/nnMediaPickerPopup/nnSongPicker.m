//
//  nnSongPicker.m
//
//  Created by Cady Holmes on 9/4/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "nnSongPicker.h"

@implementation nnSongPicker

+ (nnSongPicker *)initWithID:(int)ID {
    
    nnSongPicker *picker = [[nnSongPicker alloc] init];
    picker.ID = [NSString stringWithFormat:@"%d",ID];
    
    return picker;
}

- (id)initWithFontSize:(CGFloat)size andOrigin:(CGPoint)origin andID:(int)ID {
    self.ID = [NSString stringWithFormat:@"%d",ID];
    CGRect rect = CGRectMake(origin.x, origin.y, size*9, size*2.5);
    
    if ((self = [super initWithFrame:rect])) {
        
        self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.button.frame = CGRectMake(0, 0, size*6, self.frame.size.height);
        [self.button setTitle:@"Pick Song" forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont fontWithName:@"Georgia" size:size];
        
        [self.button addTarget:self action:@selector(openLibrary) forControlEvents:UIControlEventTouchUpInside];
        //[self.button setBackgroundColor:[UIColor redColor]];
        [self addSubview:self.button];
        
        //[self setBackgroundColor:[UIColor greenColor]];
        
    }
    return self;
}

- (void)openLibrary {
    
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems   = NO;
    mediaPicker.showsCloudItems = NO;
    mediaPicker.prompt = @"Only songs downloaded to your device will be shown.";
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC presentViewController:mediaPicker animated:YES completion:nil];
}

- (void)mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *selectedSong = [mediaItemCollection items];
        if (mediaItemCollection) {
            
            self.song = [selectedSong objectAtIndex:0];
            
            if (self.song.assetURL) {
                
                self.songURL = [self.song valueForProperty:MPMediaItemPropertyAssetURL];
                UIViewController *currentTopVC = [self currentTopViewController];
                [currentTopVC dismissViewControllerAnimated:YES completion:nil];
            }
        }
        
        id<nnSongPickerDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(songPickerDidFinish:)]) {
            [strongDelegate songPickerDidFinish:self];
        }
    });
}

- (void)mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
    
    id<nnSongPickerDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(songPickerDidCancel:)]) {
        [strongDelegate songPickerDidCancel:self];
    }
    
    UIViewController *currentTopVC = [self currentTopViewController];
    [currentTopVC dismissViewControllerAnimated:YES completion:nil];
    //[currentTopVC.navigationController popViewControllerAnimated:YES];
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
