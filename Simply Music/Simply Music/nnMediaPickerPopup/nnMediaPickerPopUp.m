//
//  nnMediaPickerPopUp.m
//
//  Created by Cady Holmes on 9/13/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "nnMediaPickerPopUp.h"

@implementation nnMediaPickerPopUp {
    BOOL empty;
}

- (UIViewController *)currentTopViewController {
    UIViewController *topVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

+ (nnMediaPickerPopUp *)initWithID:(int)ID {
    
    nnMediaPickerPopUp *popup = [[nnMediaPickerPopUp alloc] init];
    popup.ID = [NSString stringWithFormat:@"%d",ID];
    popup.layer.masksToBounds = YES;
    popup.picker = [nnSongPicker initWithID:ID];
    popup.picker.delegate = popup;
    popup.currentlyPlaying = -1;
    
    return popup;
}

- (void)setupUI {
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"make table");
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:@"MainPlaylist.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            
            //NSArray *tabData = [self listDocumentsDirectoryContentsWithURL:NO];
            NSArray *urls = [self listDocumentsDirectoryContentsWithURL:YES];
            
            self.mainPlaylist = [[NSArray alloc] initWithContentsOfFile:path];
            
            if (self.mainPlaylist) {
                if ([self.mainPlaylist firstObject]) {
                    self.tableData = [self.mainPlaylist firstObject];
                }
                
                if ([self.mainPlaylist lastObject]) {
                    //self.theFileURLs = [self.mainPlaylist lastObject];
                    
                    NSString* sourcePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    
                    NSMutableArray *urls = [[NSMutableArray alloc] init];
                    
                    [self.tableData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSString *theFile = [obj lastPathComponent];
                        [urls addObject:[sourcePath stringByAppendingPathComponent:theFile]];
                    }];
                    
                    self.theFileURLs = [NSArray arrayWithArray:urls];
                }
                
                BOOL test = NO;
                NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.theFileURLs];
                NSMutableArray *tempArray2 = [NSMutableArray arrayWithArray:self.tableData];
                
                if (urls.count > self.theFileURLs.count) {
                    
                    for (NSString *url in urls) {
                        for (NSString *url2 in self.theFileURLs) {
                            if ([url isEqualToString:url2]) {
                                test = YES;
                            }
                        }
                        if (!test) {
                            [tempArray addObject:url];
                            [tempArray2 addObject:[url lastPathComponent]];
                        } else {
                            test = NO;
                        }
                    }
                    
                    self.theFileURLs = [NSArray arrayWithArray:tempArray];
                    self.tableData = [NSArray arrayWithArray:tempArray2];
                    
                } else if (urls.count < self.theFileURLs.count) {
                    
                    for (NSString *url in self.theFileURLs) {
                        for (NSString *url2 in urls) {
                            if ([url isEqualToString:url2]) {
                                test = YES;
                            }
                        }
                        if (!test) {
                            [tempArray removeObject:url];
                            [tempArray2 removeObject:[url lastPathComponent]];
                        } else {
                            test = NO;
                        }
                    }
                    
                    self.theFileURLs = [NSArray arrayWithArray:tempArray];
                    self.tableData = [NSArray arrayWithArray:tempArray2];
                }
            }
            
            //[fileManager removeItemAtPath:path error:nil];
        }
        
        [self makeTableView];
    });
//    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
//    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCancel:)];
//    [self.containerView  addGestureRecognizer:tap];
//    [self addSubview:self.containerView];
//    
//    UIImage *noteIcon = [UIImage imageNamed:@"note.pdf"];
//    UIImage *fileIcon = [UIImage imageNamed:@"file.pdf"];
//    UIImage *cancelIcon = [UIImage imageNamed:@"close.pdf"];
//   
//    UIButton *noteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [noteButton addTarget:self action:@selector(pickSong:) forControlEvents:UIControlEventTouchUpInside];
//    [noteButton setBackgroundImage:noteIcon forState:UIControlStateNormal];
//    
//    UIButton *fileButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [fileButton addTarget:self action:@selector(pickFile:) forControlEvents:UIControlEventTouchUpInside];
//    [fileButton setBackgroundImage:fileIcon forState:UIControlStateNormal];
//    
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [cancelButton addTarget:self action:@selector(pickCancel:) forControlEvents:UIControlEventTouchUpInside];
//    [cancelButton setBackgroundImage:cancelIcon forState:UIControlStateNormal];
//    
//    float dim = self.frame.size.height*.75;
//    
//    noteButton.frame = CGRectMake(0, 0, dim, dim);
//    noteButton.center = CGPointMake(self.frame.size.width*.18, self.frame.size.height/2);
//    
//    fileButton.frame = CGRectMake(0, 0, dim, dim);
//    fileButton.center = CGPointMake(self.frame.size.width*.5, self.frame.size.height/2);
//    
//    cancelButton.frame = CGRectMake(0, 0, dim, dim);
//    cancelButton.center = CGPointMake(self.frame.size.width*.82, self.frame.size.height/2);
//    
//    [self.containerView addSubview:noteButton];
//    [self.containerView addSubview:fileButton];
//    [self.containerView addSubview:cancelButton];
//    
//    //NSLog(@"setup popup ui");
}

- (void)pickSong:(UIButton*)button {
    [self animateButtonTapped:button];
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(mediaLibraryPicked:)]) {
        [strongDelegate mediaLibraryPicked:self];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.picker openLibrary];
    });
}

- (void)pickFile:(UIButton*)button {
    [self animateButtonTapped:button];
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSLog(@"make table");
        [self makeTableView]; 
    });
}

- (void)pickCancel:(UIButton*)button {
    [self animateButtonTapped:button];
    [self hideWithAnimated:YES];
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(popupDidCancel:)]) {
        [strongDelegate popupDidCancel:self];
    }
    //NSLog(@"%@",self.picker.songURL);
}

- (void)tapCancel:(UIGestureRecognizer *)sender {
    [self hideWithAnimated:YES];
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(popupDidCancel:)]) {
        [strongDelegate popupDidCancel:self];
    }
    //NSLog(@"%@",self.picker.songURL);
}

- (void)songPickerDidFinish:(nnSongPicker *)picker {
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(songPickerDidFinish:)]) {
        [strongDelegate songPickerDidFinish:self];
    }
    //NSLog(@"picker did finish");
}
- (void)songPickerDidCancel:(nnSongPicker *)picker {
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(songPickerDidCancel:)]) {
        [strongDelegate songPickerDidCancel:self];
    }
    //NSLog(@"picker did cancel");
}

- (void)makeTableView {
    
    if (self.hasAds) {
        table = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        //[self getTableData];
        
        self.tableData = [self listDocumentsDirectoryContentsWithURL:NO];
        self.theFileURLs = [self listDocumentsDirectoryContentsWithURL:YES];

        if ([self.tableData count] < 1) {
            empty = YES;
            self.tableData = @[@"Use the web uploader to add songs."];
        }
        
        table.delegate = self;
        table.dataSource = self;
        
        table.allowsSelectionDuringEditing = YES;
        table.allowsSelection = YES;
        table.allowsMultipleSelectionDuringEditing = NO;
        
        table.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
        
        [table setAlpha:0];
        [self addSubview:table];
        
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [table setAlpha:1];
                             [self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [[UIScreen mainScreen] bounds].size.height*.7)];
                             [self setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
                             [table setFrame:self.bounds];
                             
                         } completion:^(BOOL finished){
                             if (finished) {
                             }
                         }
         ];
    } else {
        table = [[BVReorderTableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        //[self getTableData];
        
        if (!self.mainPlaylist) {
            self.tableData = [self listDocumentsDirectoryContentsWithURL:NO];
            self.theFileURLs = [self listDocumentsDirectoryContentsWithURL:YES];
        }
        
        if ([self.tableData count] < 1) {
            empty = YES;
            self.tableData = @[@"Use the web uploader to add your own music."];
        }
        
        table.delegate = self;
        table.dataSource = self;
        
        table.allowsSelectionDuringEditing = YES;
        table.allowsSelection = YES;
        
        table.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
        
        [table setAlpha:0];
        [self addSubview:table];
        
        [UIView animateWithDuration:0.3
                              delay:0.1
                            options: UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [table setAlpha:1];
                             [self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, [[UIScreen mainScreen] bounds].size.height*.7)];
                             [self setCenter:CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2)];
                             [table setFrame:self.bounds];
                             
                         } completion:^(BOOL finished){
                             if (finished) {
                             }
                         }
         ];
        
        
    }

}

//- (void)getTableData {
//    NSArray *array = [self listDocumentsDirectoryContentsFileName];
//    NSLog(@"%@",array);
//    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.wav'"]];
//    array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mp3'"]];
//    NSMutableArray *arr = [NSMutableArray arrayWithArray:array];
//    
//    if ([arr containsObject:@"player101.wav"]) {
//        [arr removeObject:@"player101.wav"];
//    }
//    if ([arr containsObject:@"player102.wav"]) {
//        [arr removeObject:@"player102.wav"];
//    }
//    if ([arr containsObject:@"player103.wav"]) {
//        [arr removeObject:@"player103.wav"];
//    }
//    
//    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
//    NSError * error;
//    NSArray * array2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
//    array2 = [array2 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.wav'"]];
//    array2 = [array2 filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.mp3'"]];
//    
//    [arr addObjectsFromArray:array2];
//    self.tableData = [NSArray arrayWithArray:arr];
//}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    int rows = (int)[self.tableData count];
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    CGFloat fontSize = [nnKit fontSize:2];
    cell.textLabel.font = [UIFont fontWithName:nnKitGlobalFont size:fontSize];
    if (!self.hasAds) {
        // You will have to manually configure what the 'empty' row looks like in this
        // method. Your dummy object can be something entirely different. It doesn't
        // have to be a string.
        if ([[_objects objectAtIndex:indexPath.row] isKindOfClass:[NSString class]] &&
            [[_objects objectAtIndex:indexPath.row] isEqualToString:@"   "]) {
            //NSLog(@"1");
            cell.textLabel.text = @"";
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            //NSLog(@"2");
            //NSDate *object = _objects[indexPath.row];
            //cell.textLabel.text = [object description];
            [cell.textLabel setText:[self.tableData objectAtIndex:indexPath.row]];
            
            if (self.currentlyPlaying == indexPath.row) {
                cell.backgroundColor = UIColorFromHex(0x5B8BB0);
                cell.layer.cornerRadius = 6;
                cell.layer.masksToBounds = YES;
                [nnKit animatePulse:cell.textLabel.layer shrinkTo:.985 withDuration:1];
                //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                cell.backgroundColor = table.backgroundColor;
                //cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        
    } else {
//        static NSString *CellIdentifier = @"Cell";
//        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        
//        if (cell == nil) {
//            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
        
        [cell.textLabel setText:[self.tableData objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

// This method is called when the long press gesture is triggered starting the re-ording process.
// You insert a blank row object into your data source and return the object you want to save for
// later. This method is only called once.
- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"%@",self.theFileURLs);
    
    tabObj = nil;
    urlObj = nil;
    
    id object = [_objects objectAtIndex:indexPath.row];
    // Your dummy object can be something entirely different. It doesn't
    // have to be a string.
    [_objects replaceObjectAtIndex:indexPath.row withObject:@"   "];
    
    NSMutableArray *tabData = [NSMutableArray arrayWithArray:self.tableData];
    NSMutableArray *urls = [NSMutableArray arrayWithArray:self.theFileURLs];
    
    tabObj = [tabData objectAtIndex:indexPath.row];
    urlObj = [urls objectAtIndex:indexPath.row];
    
    [tabData replaceObjectAtIndex:indexPath.row withObject:@"   "];
    [urls replaceObjectAtIndex:indexPath.row withObject:@"   "];
    
    self.tableData = [NSArray arrayWithArray:tabData];
    self.theFileURLs = [NSArray arrayWithArray:urls];
    
    return object;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process.
- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    rowIndex = (int)fromIndexPath.row;
    
    id object = [_objects objectAtIndex:fromIndexPath.row];
    [_objects removeObjectAtIndex:fromIndexPath.row];
    [_objects insertObject:object atIndex:toIndexPath.row];
    
    NSMutableArray *tabData = [NSMutableArray arrayWithArray:self.tableData];
    NSMutableArray *urls = [NSMutableArray arrayWithArray:self.theFileURLs];
    
    object = [tabData objectAtIndex:fromIndexPath.row];
    [tabData removeObjectAtIndex:fromIndexPath.row];
    [tabData insertObject:object atIndex:toIndexPath.row];
    
    object = [urls objectAtIndex:fromIndexPath.row];
    [urls removeObjectAtIndex:fromIndexPath.row];
    [urls insertObject:object atIndex:toIndexPath.row];
    
    self.tableData = [NSArray arrayWithArray:tabData];
    self.theFileURLs = [NSArray arrayWithArray:urls];
    
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(cellMoved:fromIndex:toIndex:)]) {
        [strongDelegate cellMoved:self fromIndex:(int)fromIndexPath.row toIndex:(int)toIndexPath.row];
    }
}


// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.
- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath; {
    [_objects replaceObjectAtIndex:indexPath.row withObject:object];
    //NSLog(@"%@",object);
    
    NSMutableArray *tabData = [NSMutableArray arrayWithArray:self.tableData];
    NSMutableArray *urls = [NSMutableArray arrayWithArray:self.theFileURLs];
    
    [tabData replaceObjectAtIndex:indexPath.row withObject:tabObj];
    [urls replaceObjectAtIndex:indexPath.row withObject:urlObj];
    
    self.tableData = [NSArray arrayWithArray:tabData];
    self.theFileURLs = [NSArray arrayWithArray:urls];
    
    self.mainPlaylist = @[self.tableData,self.theFileURLs];
    
    [self saveMainPlaylist];
    
    //NSLog(@"%@",self.theFileURLs);
    // do any additional cleanup here
}

- (void)saveMainPlaylist {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array;
        //NSString *ipAddress = [NSString stringWithFormat:@"0"];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [path stringByAppendingPathComponent:@"MainPlaylist.plist"];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
        array = [NSArray arrayWithArray:self.mainPlaylist];
        [fileManager createFileAtPath:path
                             contents:nil
                           attributes:nil];
        [array writeToFile:path atomically:YES];
    });
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)theTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSString *component = [self.tableData objectAtIndex:indexPath.row];
//    NSArray *array = [self.tableData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self BEGINSWITH 'GRAIN__'"]];
//    if ([array containsObject:component]) {
//        component = [[NSBundle mainBundle] pathForResource:component ofType:nil];
//    } else {
//        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//        component = [documentsPath stringByAppendingPathComponent:component];
//    }
    if (empty) {
        UIViewController *currentTopVC = [self currentTopViewController];
//        WebUploadViewController *vc = [[WebUploadViewController alloc] init];
//        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [currentTopVC dismissViewControllerAnimated:YES completion:nil];
    } else {
        self.currentFileURL = [self fileURL:(int)indexPath.row];
        
        id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
        if ([strongDelegate respondsToSelector:@selector(filePicked:row:)]) {
            [strongDelegate filePicked:self row:(int)indexPath.row];
        }
        
        [table removeFromSuperview];
        table = nil;
        [self hideWithAnimated:YES];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL ads = YES;
    if (self.hasAds) {
        ads = NO;
    }
    return ads;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if (self.currentlyPlaying == indexPath.row) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Unable to Delete Track"
                                                                                     message: @"Everything's gonna break if you try to delete the CURRENTLY SELECTED track. It's ok though (really). Please select a different track before trying to delete this one."
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
        } else {
            [self deleteFile:[self.tableData objectAtIndex:indexPath.row]];
            
            NSMutableArray *array = [NSMutableArray arrayWithArray:self.tableData];
            [array removeObjectAtIndex:indexPath.row];
            self.tableData = [NSArray arrayWithArray:array];
            
            array = [NSMutableArray arrayWithArray:self.theFileURLs];
            [array removeObjectAtIndex:indexPath.row];
            self.theFileURLs = array;
            
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

- (void)deleteFile:(NSString*)fileName {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (NSString*)fileURL:(int)index {
    NSString *fileURL = [self.theFileURLs objectAtIndex:index];
    
    return fileURL;
}

-(NSArray *)listDocumentsDirectoryContentsWithURL:(BOOL)url
{
    NSString* sourcePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSArray* dirs = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:sourcePath
//                                                                        error:NULL];
    
    // Application documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsURL
                                                              includingPropertiesForKeys:@[NSURLContentModificationDateKey]
                                                                                 options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                   error:nil];
    
    NSArray *sortedContent = [directoryContent sortedArrayUsingComparator:
                              ^(NSURL *file1, NSURL *file2)
                              {
                                  // compare
                                  NSDate *file1Date;
                                  [file1 getResourceValue:&file1Date forKey:NSURLContentModificationDateKey error:nil];
                                  
                                  NSDate *file2Date;
                                  [file2 getResourceValue:&file2Date forKey:NSURLContentModificationDateKey error:nil];
                                  
                                  // Ascending:
                                  return [file1Date compare: file2Date];
                                  // Descending:
                                  //return [file2Date compare: file1Date];
                              }];
    
    NSMutableArray *mp3Files = [[NSMutableArray alloc] init];
    [sortedContent enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *filename = (NSString *)obj;
        NSString *theFile = [obj lastPathComponent];
        NSString *extension = [[filename pathExtension] lowercaseString];
        
        if ([extension isEqualToString:@"mp3"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"wav"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"aif"] || [extension isEqualToString:@"aiff"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"aifc"] || [extension isEqualToString:@"alac"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"caf"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"aac"] || [extension isEqualToString:@"m4a"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"mp4"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
        if ([extension isEqualToString:@"3gp"] || [extension isEqualToString:@"3g2"]) {
            if (url) {
                //[mp3Files addObject:filename];
                [mp3Files addObject:[sourcePath stringByAppendingPathComponent:theFile]];
            } else {
                [mp3Files addObject:theFile];
            }
        }
    }];
    
    NSArray *files = [NSArray arrayWithArray:mp3Files];
    
    //NSLog(@"%@",files);
    
    return files;
}

//-(NSArray *)listDocumentsDirectoryContentsFileName
//{
//    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:NULL];
//    return directoryContent;
//}

- (void)showFromView:(UIView *)view animated:(BOOL)animated
{
    self.frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width*.95, [[UIScreen mainScreen] bounds].size.height*.2);
    self.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, [[UIScreen mainScreen] bounds].size.height/2);
    self.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1];
    self.layer.cornerRadius = 12;
    
    [self setupUI];
    
    if (animated) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{

        }];
        [self.layer addAnimation:_showAnimation() forKey:nil];
        [CATransaction commit];
    }
    self.layer.opacity = 1;
}

- (void)hideWithAnimated:(BOOL)animated
{
    if (animated) {
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            [self.layer removeAnimationForKey:@"opacity"];
            [self.layer removeAnimationForKey:@"transform"];
            [self removeFromSuperview];
            if (table) {
                [table removeFromSuperview];
            }
        }];
        [self.layer addAnimation:_hideAnimation() forKey:nil];
        [CATransaction commit];
    }else {
        [self removeFromSuperview];
    }
    self.layer.opacity = 0;
    
    id<nnMediaPickerPopUpDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(popupDidHide:)]) {
        [strongDelegate popupDidHide:self];
    }
}

- (void)animateButtonTapped:(UIView*)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15f
                              delay:0.0f
             usingSpringWithDamping:.2f
              initialSpringVelocity:10.f
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
                         }
                         completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.3f
                                                   delay:0.0f
                                  usingSpringWithDamping:.3f
                                   initialSpringVelocity:10.0f
                                                 options:UIViewAnimationOptionAllowUserInteraction
                                              animations:^{
                                                  view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                                              }
                                              completion:^(BOOL finished) {
                                              }];
                         }];
    });
}

static CAAnimation* _showAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@0.0];
    [opacity setToValue:@1.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.2;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}

static CAAnimation* _hideAnimation()
{
    CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.00, 1.00, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.05, 1.05, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.95, 0.95, 1.0)]];
    transform.values = values;
    
    CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacity setFromValue:@1.0];
    [opacity setToValue:@0.0];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = 0.2;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [group setAnimations:@[transform, opacity]];
    return group;
}

@end
