//
//  nnMediaPickerPopUp.h
//
//  Created by Cady Holmes on 9/13/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nnSongPicker.h"
#import "BVReorderTableView.h"
#import "nnKit.h"

@protocol nnMediaPickerPopUpDelegate;
@interface nnMediaPickerPopUp : UIView <UITableViewDataSource,UITableViewDelegate,nnSongPickerDelegate> {
    UITableView *table;
    NSMutableArray *_objects;
    int rowIndex;
    
    id tabObj;
    id urlObj;
    
    NSURL *urlPath;
    NSString *stringPath;
    int levelCount;
}

@property (nonatomic, weak) id<nnMediaPickerPopUpDelegate> delegate;
@property (nonatomic, strong) nnSongPicker *picker;
//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *currentFileURL;
@property (nonatomic, strong) NSArray *theFileURLs;
@property (nonatomic, strong) NSArray *tableData;
@property (nonatomic, strong) NSArray *mainPlaylist;
@property (nonatomic) BOOL hasAds;
@property (nonatomic) int currentlyPlaying;

- (void)showFromView:(UIView *)view animated:(BOOL)animated;
- (void)hideWithAnimated:(BOOL)animated;
+ (nnMediaPickerPopUp *)initWithID:(int)ID;
- (NSString*)fileURL:(int)index;

@end


@protocol nnMediaPickerPopUpDelegate <NSObject>
- (void)songPickerDidFinish:(nnMediaPickerPopUp *)popup;
- (void)songPickerDidCancel:(nnMediaPickerPopUp *)popup;
- (void)filePicked:(nnMediaPickerPopUp *)popup row:(int)row;
- (void)mediaLibraryPicked:(nnMediaPickerPopUp *)popup;
- (void)popupDidCancel:(nnMediaPickerPopUp *)popup;
- (void)popupDidHide:(nnMediaPickerPopUp *)popup;

- (void)cellMoved:(nnMediaPickerPopUp *)popup fromIndex:(int)from toIndex:(int)to;
@end
