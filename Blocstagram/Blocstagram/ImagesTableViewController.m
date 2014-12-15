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

@interface ImagesTableViewController () <MediaTableViewCellDelegate, UIViewControllerTransitioningDelegate>

// Track which view was tapped most recently
@property (nonatomic, weak) UIImageView *lastTappedImageView;

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
    
    // Add this in order to get something on launch
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:nil];
}


#pragma mark - Pull To Refresh Method

- (void)refreshControlDidFire:(UIRefreshControl *)sender {
    [[DataSource sharedInstance] requestNewItemsWithCompletionHandler:^(NSError *error) {
        [sender endRefreshing];
    }];
}


#pragma mark - Table view data source

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
        return 350;
    } else {
        return 150;
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


#pragma mark - KVO Removal

- (void)dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"mediaItems"];
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

@end
