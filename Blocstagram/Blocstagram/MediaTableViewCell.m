//
//  MediaTableViewCell.m
//  Blocstagram
//
//  Created by Dulio Denis on 11/8/14.
//  Copyright (c) 2014 ddApps. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "Media.h"
#import "Comment.h"
#import "User.h"

@interface MediaTableViewCell()
@property (nonatomic) UIImageView *mediaImageView;
@property (nonatomic) UILabel *userNameAndCaptionLabel;
@property (nonatomic) UILabel *commentLabel;

// Auto-Layout Constraints
@property (nonatomic) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic) NSLayoutConstraint *userNameAndCaptionLabelHeightConstraint;
@property (nonatomic) NSLayoutConstraint *commentLabelHeightConstraint;
@end

static UIFont *lightFont;
static UIFont *boldFont;
static UIColor *userNameLabelGrey;
static UIColor *commentLabelGrey;
static UIColor *linkColor;
static NSParagraphStyle *paragraphStyle;

@implementation MediaTableViewCell


#pragma mark - View Lifecycle

+ (void)load {
    lightFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:11];
    boldFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:11];
    userNameLabelGrey = [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1];
    commentLabelGrey = [UIColor colorWithRed:0.898 green:0.898 blue:0.898 alpha:1];
    linkColor = [UIColor colorWithRed:0.541 green:0.494 blue:0.677 alpha:1.000];
    
    NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    mutableParagraphStyle.headIndent = 20.0;
    mutableParagraphStyle.firstLineHeadIndent = 20.0;
    mutableParagraphStyle.tailIndent = -20.0;
    mutableParagraphStyle.paragraphSpacingBefore = 5;
    
    paragraphStyle = mutableParagraphStyle;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.mediaImageView = [[UIImageView alloc] init];
        self.userNameAndCaptionLabel = [[UILabel alloc] init];
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        
        for (UIView *view in @[self.mediaImageView, self.userNameAndCaptionLabel, self.commentLabel]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _userNameAndCaptionLabel, _commentLabel);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                                                                                options:kNilOptions
                                                                                metrics:nil
                                                                                  views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_userNameAndCaptionLabel]|"
                                                                                options:kNilOptions
                                                                                metrics:nil
                                                                                  views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_commentLabel]|"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        [self.contentView addConstraints:[NSLayoutConstraint
                        constraintsWithVisualFormat:@"V:|[_mediaImageView][_userNameAndCaptionLabel][_commentLabel]"
                                                                                 options:kNilOptions
                                                                                 metrics:nil
                                                                                   views:viewDictionary]];
        
        self.imageHeightConstraint = [NSLayoutConstraint constraintWithItem:_mediaImageView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:100];
        
        
        self.userNameAndCaptionLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_userNameAndCaptionLabel
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1
                                                                                     constant:100];
        
        self.commentLabelHeightConstraint = [NSLayoutConstraint constraintWithItem:_commentLabel
                                                                         attribute:NSLayoutAttributeHeight
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:nil
                                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                                        multiplier:1
                                                                          constant:100];
        
        [self.contentView addConstraints:@[self.imageHeightConstraint, self.userNameAndCaptionLabelHeightConstraint,
                                           self.commentLabelHeightConstraint]];
    }
    return self;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Before layout, calculate the intrinsic size of the labels (the size they "want" to be),
    // and add 20 to the height for some vertical padding.
    CGSize maxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX);
    CGSize usernameLabelSize = [self.userNameAndCaptionLabel sizeThatFits:maxSize];
    CGSize commentLabelSize = [self.commentLabel sizeThatFits:maxSize];

    self.userNameAndCaptionLabelHeightConstraint.constant = usernameLabelSize.height + 20;
    self.commentLabelHeightConstraint.constant = commentLabelSize.height + 20;
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}


#pragma mark - Media Item Custom Setter

- (void)setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    
    self.mediaImageView.image = _mediaItem.image;
    self.userNameAndCaptionLabel.attributedText = [self userNameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    
    // If we have an image calculate the height otherwise the height is zero (prevent division by zero crash)
    if (_mediaItem.image) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width
        * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint.constant = 0;
    }
}


#pragma mark - Attributed String Methods

- (NSAttributedString *)userNameAndCaptionString {
    CGFloat userNameFontSize = 15;
    
    // Make a string that says "username caption text"
    NSString *baseString = [NSString stringWithFormat:@"%@ %@", self.mediaItem.user.userName, self.mediaItem.caption];
    
    // Make an Attributed String with the user name in bold
    NSMutableAttributedString *mutableUserNameAndCaptionString = [[NSMutableAttributedString alloc] initWithString:baseString attributes:@{NSFontAttributeName: [lightFont fontWithSize:userNameFontSize], NSParagraphStyleAttributeName: paragraphStyle}];
    
    NSRange userNameRange = [baseString rangeOfString:self.mediaItem.user.userName];
    [mutableUserNameAndCaptionString addAttribute:NSFontAttributeName value:[boldFont fontWithSize:userNameFontSize] range:userNameRange];
    [mutableUserNameAndCaptionString addAttribute:NSForegroundColorAttributeName value:linkColor range:userNameRange];
    
    return mutableUserNameAndCaptionString;
}


- (NSAttributedString *)commentString {
    NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] init];
    
    for (Comment *comment in self.mediaItem.comments) {
        // Make a string that says "username comment text" followed by a line break
        NSString *baseString = [NSString stringWithFormat:@"%@ %@\n", comment.from.userName, comment.text];

        // Make an Attributed String with the userName in BOLD
        NSMutableAttributedString *oneCommentString = [[NSMutableAttributedString alloc] initWithString:baseString
                    attributes:@{NSFontAttributeName: lightFont, NSParagraphStyleAttributeName: paragraphStyle}];
        NSRange userNameRange = [baseString rangeOfString:comment.from.userName];
        [oneCommentString addAttribute:NSFontAttributeName value:boldFont range:userNameRange];
        [oneCommentString addAttribute:NSForegroundColorAttributeName value:linkColor range:userNameRange];
        
        [commentString appendAttributedString:oneCommentString];
    }
    
    return commentString;
}


+ (CGFloat)heightForMediaItem:(Media *)mediaItem width:(CGFloat)width {
    // Make a cell
    MediaTableViewCell *layoutCell = [[MediaTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"layoutCell"];
    
    // Give it a media item
    layoutCell.mediaItem = mediaItem;
    
    layoutCell.frame = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    return CGRectGetMaxY(layoutCell.commentLabel.frame);
}


#pragma mark - Disabling Set Selection

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

@end
