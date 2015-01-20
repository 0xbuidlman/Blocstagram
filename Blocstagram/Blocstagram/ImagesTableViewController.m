//
//  ImagesTableViewController.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/7/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "ImagesTableViewController.h"
#import "DataSource.h"
#import "Media.h"
#import "User.h"
#import "Comment.h"
#import "MediaTableViewCell.h"
#import "MediaFullScreenViewController.h"
#import "MediaFullScreenAnimator.h"
#import "MediaShare.h"
#import "Constants.h"
#import "CameraViewController.h"
#import "ImageLibraryViewController.h"
#import "PostToInstagramViewController.h"

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate, CameraViewControllerDelegate, ImageLibraryViewControllerDelegate>

// Track which view was tapped most recently
@property (nonatomic, weak) UIImageView *lastTappedImageView;
@property (nonatomic, weak) UIView *lastSelectedCommentView;
@property (nonatomic, assign) CGFloat lastKeyboardHeightAdjustment;

@end

@implementation ImagesTableViewController


#pragma mark - View Lifecycle Methods

- (instancetype)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = kAppTitle;
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"mediaItems" options:0 context:nil];
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshControlDidFire:) forControlEvents:UIControlEventValueChanged];
    [self.tableView registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediaCell"];
    
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // If any photo capabilities are avaialable add a camera button
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ||
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        UIBarButtonItem *cameraButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraPressed:)];
        self.navigationItem.rightBarButtonItem = cameraButton;
    }
    
    // Add this in order to get something on launch
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:nil];
}


// handle this ourselves and not call super
- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath * indexPath = self.tableView.indexPathForSelectedRow;
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}



- (void)viewWillDisappear:(BOOL)animated {
    
}

#pragma mark - Pull To Refresh Method

- (void)refreshControlDidFire:(UIRefreshControl *)sender {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}


#pragma mark - Table view data source

// If a row is tapped, let's assume the user doesn't want the keyboard
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableViewCell *cell = (MediaTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell stopComposingComment];
}


- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath {
    // NOTE: instead of loading images here - we'll move that to loading images for
    // the cells currently visible on the screen starting when the scrolling slows down.
//    Media *mediaItem = [self items][indexPath.row];
//    if (mediaItem.downloadState == MediaDownloadStateNeedsImage) {
//        [[DataSource sharedInstance] downloadImageForMediaItem:mediaItem];
//    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self items].count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MediaTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mediaCell" forIndexPath:indexPath];
    cell.delegate = self;
    cell.mediaItem = [self items][indexPath.row];
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [self items][indexPath.row];
    return [MediaTableViewCell heightForMediaItem:item width:CGRectGetWidth(self.view.frame)];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [self items][indexPath.row];
    if (item) return YES;
    return NO;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Media *item = [self items][indexPath.row];
        [[DataSource sharedInstance] deleteMediaItem:item];
    }
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Media *item = [self items][indexPath.row];
    if (item.image) {
        return 450;
    } else {
        return 250;
    }
}


#pragma mark - KVO Handling Methods for Pull to Refresh

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"mediaItems"]) {
        // determine what kind of change it is
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            // Someone set a brand new immage array
            [self.tableView reloadData];
        } else if ((kindOfChange == NSKeyValueChangeInsertion) ||
                   (kindOfChange == NSKeyValueChangeRemoval) ||
                   (kindOfChange == NSKeyValueChangeReplacement)) {
            // if its an insertion, removal, or replacement get a list of the index/indices
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            // Convert the NSIndexSet to an NSArray of NSIndexedPaths
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            // Call BeginUpdate to tell the tableView we're about to make changes
            [self.tableView beginUpdates];
            
            // then tell the tableView what the specific changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            // Tell the tableView that we have completed telling about changes - completes the animation
            [self.tableView endUpdates];
        }
    }
}


#pragma mark - Infinite Scrolling Methods with UIScrollView Delegate

- (void)infiniteScrollIfNecessary {
    NSIndexPath *bottomIndexPath = [[self.tableView indexPathsForVisibleRows] lastObject];
    
    if (bottomIndexPath && bottomIndexPath.row == [self items].count -1) {
        // if the very last cell is on the screen
        [[DataSource sharedInstance] requestOldItemsWithCompletionHandler:nil];
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self infiniteScrollIfNecessary];
}
*/

// Using a different delegate method to reduce the number of times we call infiniteScrollIfNecessary
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self infiniteScrollIfNecessary];
}


// Do not load images if the user is scrolling past them in order to reduce jerkiness
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ((scrollView.decelerationRate == UIScrollViewDecelerationRateNormal) && (!scrollView.dragging)) {
        
        // Load media items for only those cells that are visible
        NSArray *visibleCells = [self.tableView visibleCells];
        for (MediaTableViewCell *cell in visibleCells) {
            [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
        }
    }
}


#pragma mark - KVO & Keyboard Notification Removal

- (void)dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Convenience Methods

- (NSArray *)items {
    return [DataSource sharedInstance].mediaItems;
}


#pragma mark - TableViewCell Delegate Method

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView {
    self.lastTappedImageView = imageView;
    MediaFullScreenViewController *fullScreenViewController =
                                    [[MediaFullScreenViewController alloc] initWithMedia:cell.mediaItem];
    
    fullScreenViewController.transitioningDelegate = self;
    
    // Does not work with UIModalPresentationCustom - get a blank screen in the dismiss
    fullScreenViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:fullScreenViewController animated:YES completion:nil];
}


- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView {
    [MediaShare share:self withCaption:cell.mediaItem.caption withImage:cell.mediaItem.image];
}


// reload image
- (void)didDoubleTapCell:(MediaTableViewCell *)cell {
    NSLog(@"Retry image download");
    [[DataSource sharedInstance] downloadImageForMediaItem:cell.mediaItem];
}


// like button
- (void)cellDidPressLikeButton:(MediaTableViewCell *)cell {
    [[DataSource sharedInstance] toggleLikeOnMediaItem:cell.mediaItem];
}


#pragma mark - Comment Delegate Methods
- (void)cellWillStartComposingComment:(MediaTableViewCell *)cell {
    self.lastSelectedCommentView = (UIView *)cell.commentView;
}


- (void)cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment {
    [[DataSource sharedInstance] commentOnMediaItem:cell.mediaItem withCommentText:comment];
}


#pragma mark - View Controller Transitioning Delegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    MediaFullScreenAnimator *animator = [[MediaFullScreenAnimator alloc] init];
    animator.presenting = YES;
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}


- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    MediaFullScreenAnimator *animator = [[MediaFullScreenAnimator alloc] init];
    animator.cellImageView = self.lastTappedImageView;
    return animator;
}


#pragma mark - Keyboard Handling Methods

- (void)keyboardWillShow:(NSNotification *)notification {
    // Get the frame of the keyboard within self.view's coordinate system
    NSValue *frameValue = notification.userInfo[UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrameInScreenCoordinates = frameValue.CGRectValue;
    CGRect keyboardFrameInViewCoordinates = [self.navigationController.view convertRect:keyboardFrameInScreenCoordinates fromView:nil];
    
    // Get the frame of the comment view in the same coordinate system
    CGRect commentViewFrameInViewCoordinates = [self.navigationController.view convertRect:self.lastSelectedCommentView.bounds fromView:self.lastSelectedCommentView];
    
    CGPoint contentOffset = self.tableView.contentOffset;
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    CGFloat heightToScroll = 0;
    
    CGFloat keyboardY = CGRectGetMinY(keyboardFrameInViewCoordinates);
    CGFloat commentViewY = CGRectGetMinY(commentViewFrameInViewCoordinates);
    CGFloat difference = commentViewY - keyboardY;
    
    if (difference > 0) {
        heightToScroll += difference;
    }
    
    if (CGRectIntersectsRect(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates)) {
        // The two frames intersect case (the keyboard would block the view)
        CGRect intersectionRect = CGRectIntersection(keyboardFrameInViewCoordinates, commentViewFrameInViewCoordinates);
        heightToScroll += CGRectGetHeight(intersectionRect);
    }
    
    if (heightToScroll > 0) {
        contentInsets.bottom += heightToScroll;
        scrollIndicatorInsets.bottom += heightToScroll;
        contentOffset.y += heightToScroll;
        
        NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        
        NSTimeInterval duration = durationNumber.doubleValue;
        UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
        UIViewAnimationOptions options = curve << 16;
        
        [UIView animateWithDuration:duration delay:0 options:options animations:^{
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
            self.tableView.contentOffset = contentOffset;
        } completion:nil];
    }
    
    self.lastKeyboardHeightAdjustment = heightToScroll;
}


- (void)keyboardWillHide:(NSNotification *)notification
{
    UIEdgeInsets contentInsets = self.tableView.contentInset;
    contentInsets.bottom -= self.lastKeyboardHeightAdjustment;
    
    UIEdgeInsets scrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    scrollIndicatorInsets.bottom -= self.lastKeyboardHeightAdjustment;
    
    NSNumber *durationNumber = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curveNumber = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    
    NSTimeInterval duration = durationNumber.doubleValue;
    UIViewAnimationCurve curve = curveNumber.unsignedIntegerValue;
    UIViewAnimationOptions options = curve << 16;
    
    [UIView animateWithDuration:duration delay:0 options:options animations:^{
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = scrollIndicatorInsets;
    } completion:nil];
}


#pragma mark - Camera, CameraViewControllerDelegate, and ImageLibraryViewControllerDelegate

- (void)cameraPressed:(UIBarButtonItem *) sender {
    UIViewController *imageVC;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        CameraViewController *cameraVC = [[CameraViewController alloc] init];
        cameraVC.delegate = self;
        imageVC = cameraVC;
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        ImageLibraryViewController *imageLibraryVC = [[ImageLibraryViewController alloc] init];
        imageLibraryVC.delegate = self;
        imageVC = imageLibraryVC;
    }
    
    if (imageVC) {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:imageVC];
        [self presentViewController:nav animated:YES completion:nil];
    }

    return;
}


- (void)cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image {
     [self handleImage:image withNavigationController:cameraViewController.navigationController];
}


- (void)imageLibraryViewController:(ImageLibraryViewController *)imageLibraryViewController didCompleteWithImage:(UIImage *)image {
     [self handleImage:image withNavigationController:imageLibraryViewController.navigationController];
}


#pragma mark - Handle Image for Posting to Instagram

- (void)handleImage:(UIImage *)image withNavigationController:(UINavigationController *)nav {
    if (image) {
        PostToInstagramViewController *postVC = [[PostToInstagramViewController alloc] initWithImage:image];
        [nav pushViewController:postVC animated:YES];
    } else {
        [nav dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
