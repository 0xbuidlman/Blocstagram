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
#import "Constants.h"
#import "LikeButton.h"

@interface MediaTableViewCell() <UIGestureRecognizerDelegate>
@property (nonatomic) UIImageView *mediaImageView;
@property (nonatomic) UILabel *userNameAndCaptionLabel;
@property (nonatomic) UILabel *commentLabel;
@property (nonatomic) UILabel *likes;
@property (nonatomic) LikeButton *likeButton;

// Auto-Layout Constraints
@property (nonatomic) NSLayoutConstraint *imageHeightConstraint;
@property (nonatomic) NSLayoutConstraint *userNameAndCaptionLabelHeightConstraint;
@property (nonatomic) NSLayoutConstraint *commentLabelHeightConstraint;

// Gesture Recognizers
@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

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
    lightFont = [UIFont fontWithName:kLightFont size:11];
    boldFont = [UIFont fontWithName:kBoldFont size:11];
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
        self.mediaImageView.userInteractionEnabled = YES;
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        self.tapGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.tapGestureRecognizer];
        
        self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        self.longPressGestureRecognizer.delegate = self;
        [self.mediaImageView addGestureRecognizer:self.longPressGestureRecognizer];
        
        // double tap to retry image download
        self.doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapFired:)];
        self.doubleTapGestureRecognizer.delegate = self;
        self.doubleTapGestureRecognizer.numberOfTouchesRequired = 2;
        [self.mediaImageView addGestureRecognizer:self.doubleTapGestureRecognizer];
        
        self.userNameAndCaptionLabel = [[UILabel alloc] init];
        self.commentLabel = [[UILabel alloc] init];
        self.commentLabel.numberOfLines = 0;
        self.commentLabel.backgroundColor = commentLabelGrey;
        
        self.likes = [[UILabel alloc] init];
        self.likes.backgroundColor = commentLabelGrey;
        self.likes.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];;
        
        self.likeButton = [[LikeButton alloc] init];
        [self.likeButton addTarget:self action:@selector(likePressed:) forControlEvents:UIControlEventTouchUpInside];
        self.likeButton.backgroundColor = userNameLabelGrey;
        
        for (UIView *view in @[self.mediaImageView, self.userNameAndCaptionLabel, self.commentLabel, self.likes, self.likeButton]) {
            [self.contentView addSubview:view];
            view.translatesAutoresizingMaskIntoConstraints = NO;
        }
        
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(_mediaImageView, _userNameAndCaptionLabel, _commentLabel, _likes, _likeButton);
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_mediaImageView]|"
                                                                                options:kNilOptions
                                                                                metrics:nil
                                                                                  views:viewDictionary]];
        /*
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_userNameAndCaptionLabel]|"
                                                                                options:kNilOptions
                                                                                metrics:nil
                                                                                  views:viewDictionary]]; */
        // Note: This does not work with 10K+ Likes which is common on Instagram
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_userNameAndCaptionLabel][_likes(==9)][_likeButton(==38)]|"
                                                                                 options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom
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
        
        // Register as an Observer of the LikesNotification
        [[NSNotificationCenter defaultCenter] addObserverForName:kLikesNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            Media *mediaItem = note.object;
            self.likes.text = [NSString stringWithFormat:@"%@",mediaItem.likes];
        }];
        
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

    // If we have an image calculate the height otherwise the height is zero (prevent division by zero crash)
    // moved from setMediaItem in order to remove issues when rotating
    if (_mediaItem.image) {
        self.imageHeightConstraint.constant = self.mediaItem.image.size.height / self.mediaItem.image.size.width
        * CGRectGetWidth(self.contentView.bounds);
    } else {
        self.imageHeightConstraint.constant = 300;
    }
    
    // Hide the line between cells
    self.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.bounds));
}


#pragma mark - Media Item Custom Setter

- (void)setMediaItem:(Media *)mediaItem {
    _mediaItem = mediaItem;
    
    self.mediaImageView.image = _mediaItem.image;
    self.userNameAndCaptionLabel.attributedText = [self userNameAndCaptionString];
    self.commentLabel.attributedText = [self commentString];
    self.likeButton.likeButtonState = mediaItem.likeState;
    self.likes.text = [NSString stringWithFormat:@"%@",mediaItem.likes];
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


#pragma mark - Gesture Action Methods

- (void)tapFired:(UITapGestureRecognizer *)sender {
    [self.delegate cell:self didTapImageView:self.mediaImageView];
}


- (void)longPressFired:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.delegate cell:self didLongPressImageView:self.mediaImageView];
    }
}

- (void)doubleTapFired:(UITapGestureRecognizer *)sender {
    [self.delegate didDoubleTapCell:self];
}


#pragma mark - Liking Action Method

- (void)likePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self];
}


#pragma mark - UIGestureRecognizer Delegate Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.isEditing == NO;
}

#pragma mark - KVO for LikesNotification

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (keyPath == kLikesNotification) {
        self.likes.text = [NSString stringWithFormat:@"%@",self.likes];
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end


