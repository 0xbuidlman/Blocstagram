//
//  MediaTableViewCell.h
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Media;

@interface MediaTableViewCell : UITableViewCell

@property (nonatomic) Media *mediaItem;
+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width;

@end
