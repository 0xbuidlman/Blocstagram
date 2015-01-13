//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Media, MediaTableViewCell, ComposeCommentView;

@protocol MediaTableViewCellDelegate <NSObject>

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;
- (void)didDoubleTapCell:(MediaTableViewCell *)cell;
- (void)cellDidPressLikeButton:(MediaTableViewCell *)cell;
- (void)cellWillStartComposingComment:(MediaTableViewCell *)cell;
- (void)cell:(MediaTableViewCell *)cell didComposeComment:(NSString *)comment;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate>delegate;
@property (nonatomic, readonly) ComposeCommentView *commentView;

+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;
- (void)stopComposingComment;

@end
