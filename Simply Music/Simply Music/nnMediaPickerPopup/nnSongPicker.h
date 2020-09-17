//
//  nnSongPicker.h
//
//  Created by Cady Holmes on 9/4/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol nnSongPickerDelegate;
@interface nnSongPicker : UIView <MPMediaPickerControllerDelegate>

@property (nonatomic, weak) id<nnSongPickerDelegate> delegate;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) MPMediaItem *song;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSURL *songURL;

- (id)initWithFontSize:(CGFloat)size andOrigin:(CGPoint)origin andID:(int)ID;
+ (nnSongPicker *)initWithID:(int)ID;
- (void)openLibrary;

@end

@protocol nnSongPickerDelegate <NSObject>
- (void)songPickerDidFinish:(nnSongPicker *)picker;
- (void)songPickerDidCancel:(nnSongPicker *)picker;

@end
