//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Media, MediaTableViewCell;

@protocol MediaTableViewCellDelegate <NSObject>

- (void)cell:(MediaTableViewCell *)cell didTapImageView:(UIImageView *)imageView;
- (void)cell:(MediaTableViewCell *)cell didLongPressImageView:(UIImageView *)imageView;

@end

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic) Media *mediaItem;
@property (nonatomic, weak) id <MediaTableViewCellDelegate>delegate;

+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
