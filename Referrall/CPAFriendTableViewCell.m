//
//  CPAFriendTableViewCell.m
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAFriendTableViewCell.h"
#import <ParseUI/ParseUI.h>
#import "CPAConstants.h"
#import "CPAParseUtility.h"

@interface CPAFriendTableViewCell ()

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) PFImageView *userImageView;

@end

@implementation CPAFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[CPAConstants lightGrayColor]];
        
        self.mainView = [[UIView alloc] init];
        self.mainView.backgroundColor = [UIColor whiteColor];
        self.mainView.layer.shadowOpacity = 0.15;
        self.mainView.layer.shadowOffset = CGSizeMake(1.0, 1.2);
        self.mainView.layer.shadowRadius = 1.0;
        [self.contentView addSubview:self.mainView];
        
        self.userImageView  = [[PFImageView alloc] init];
        [self.userImageView setBackgroundColor:[UIColor clearColor]];
        [self.userImageView setOpaque:YES];
        [self.mainView addSubview:self.userImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.mainView addSubview:self.nameLabel];
        
        self.jobSubtitleLabel = [[UILabel alloc] init];
        [self.jobSubtitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.jobSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f]];
        [self.jobSubtitleLabel setTextColor:[UIColor grayColor]];
        [self.jobSubtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.jobSubtitleLabel setNumberOfLines:2];
        [self.mainView addSubview:self.jobSubtitleLabel];
        
        self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.addButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [self.addButton setBackgroundColor:[UIColor clearColor]];
        [self.addButton setTitle:@"Add" forState:UIControlStateNormal];
        [self.addButton setTitleColor:[CPAConstants skyBlueColor] forState:UIControlStateNormal];
        [self.addButton setBackgroundImage:[CPAParseUtility imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [self.addButton setTitle:@"Added" forState:UIControlStateSelected];
        [self.addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self.addButton setBackgroundImage:[CPAParseUtility imageWithColor:[CPAConstants skyBlueColor]] forState:UIControlStateSelected];
        self.addButton.clipsToBounds = YES;
        [self.addButton.layer setBorderColor:[CPAConstants skyBlueColor].CGColor];
        [self.addButton.layer setBorderWidth:1];
        [self.addButton.layer setCornerRadius:3];
        [self.addButton addTarget:self action:@selector(addButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.addButton];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat cellPadding = 10;
    CGFloat padding = 7.5;
    CGFloat userImageViewSize = 55;
    CGFloat addButtonWidth = 55;
    CGFloat addButtonHeight = 25;
    
    self.mainView.frame = CGRectMake(cellPadding,
                                     cellPadding,
                                     CGRectGetWidth(self.bounds) - (cellPadding * 2),
                                     userImageViewSize + (padding * 2));
    
    // Main view subviews
    self.userImageView.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                          CGRectGetMinY(self.mainView.bounds) + padding,
                                          userImageViewSize,
                                          userImageViewSize);
    
    // Main view subviews
    self.addButton.frame = CGRectMake(CGRectGetMaxX(self.mainView.bounds) - addButtonWidth - (padding * 2),
                                         CGRectGetMidY(self.mainView.bounds) - addButtonHeight / 2,
                                         addButtonWidth,
                                         addButtonHeight);
    
    // Get the total height of the labels
    CGSize maxNameLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - addButtonWidth - (padding * 5), CGFLOAT_MAX);
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:maxNameLabelSize];
    CGSize maxJobSubtitleLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - addButtonWidth - (padding * 5), CGFLOAT_MAX);
    CGSize jobSubtitleLabelSize = [self.jobSubtitleLabel sizeThatFits:maxJobSubtitleLabelSize];
    CGFloat totalLabelHeight = nameLabelSize.height + jobSubtitleLabelSize.height;
    
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.userImageView.frame) + padding,
                                      CGRectGetMidY(self.mainView.bounds) - totalLabelHeight / 2,
                                      nameLabelSize.width,
                                      nameLabelSize.height);
    
    self.jobSubtitleLabel.frame = CGRectMake(CGRectGetMaxX(self.userImageView.frame) + padding,
                                              CGRectGetMaxY(self.nameLabel.frame),
                                              jobSubtitleLabelSize.width,
                                              jobSubtitleLabelSize.height);
    
}

#pragma mark - Overrides

- (void)setUser:(PFUser *)user {
    _user = user;
    
    // Set the user image view
    self.userImageView.image = [UIImage imageNamed:@"profile"];
    if ([self.user objectForKey:@"profilePictureMedium"]) {
        self.userImageView.file = self.user[@"profilePictureMedium"];
        [self.userImageView loadInBackground];
    }
    
    // Set name
    NSString *firstName = [self.user objectForKey:@"firstName"];
    NSString *lastName = [self.user objectForKey:@"lastName"];
    NSString *fullNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self.nameLabel setText:fullNameString];

    // Set job string
    NSString *jobString = [[NSString alloc] init];
    if ([self.user objectForKey:@"jobTitle"] && [self.user objectForKey:@"company"]) {
        jobString = [NSString stringWithFormat:@"%@\n%@", [self.user objectForKey:@"jobTitle"], [self.user objectForKey:@"company"]];
    } else if ([self.user objectForKey:@"industry"]) {
        jobString = [NSString stringWithFormat:@"%@", [self.user objectForKey:@"industry"]];
    } else {
        jobString = @"";
    }
    [self.jobSubtitleLabel setText:jobString];
    
    [self layoutSubviews];
}

#pragma mark - Delegate

- (void)addButtonFired:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapAddFriendButton:)]) {
        [self.delegate cell:self didTapAddFriendButton:self.user];
    }
}

#pragma mark - Height helper method

+ (CGFloat)heightForFriendCell:(PFUser *)user width:(CGFloat)width {

    // Make a cell
    CPAFriendTableViewCell *layoutCell = [[CPAFriendTableViewCell alloc] init];
    layoutCell.user = user;
    layoutCell.bounds = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    return CGRectGetMaxY(layoutCell.mainView.frame);
}


@end
