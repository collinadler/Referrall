//
//  CPAHomeLeftPanelViewController.m
//  Referrall
//
//  Created by Collin Adler on 9/2/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAHomeLeftPanelViewController.h"
#import <ParseUI/ParseUI.h>
#import "CPAParseUtility.h"
#import "CPAConstants.h"

@interface CPAHomeLeftPanelViewController ()

@property (nonatomic, strong) UIView *mainBackgroundView;
@property (nonatomic, strong) UIView *nameBackgroundView;

@property (nonatomic, strong) PFImageView *profileImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *jobSubtitleLabel;

// Buttons
@property (nonatomic, strong) UIView *buttonBackgroundView;
@property (nonatomic, strong) UIButton *myProfileButton;
@property (nonatomic, strong) UIButton *myFriendsButton;
@property (nonatomic, strong) UIButton *logOutButton;

@end

@implementation CPAHomeLeftPanelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [CPAConstants skyBlueColor];
    
    // Refresh the current user information
    [[PFUser currentUser] fetch];
    
    self.mainBackgroundView = [[UIView alloc] init];
    self.mainBackgroundView.backgroundColor = [UIColor lightGrayColor];
    
    self.nameBackgroundView = [[UIView alloc] init];
    self.nameBackgroundView.backgroundColor = [UIColor whiteColor];

    // Make the profile image view
    self.profileImageView = [[PFImageView alloc] init];
    [self.profileImageView setContentMode:UIViewContentModeScaleAspectFill];
    self.profileImageView.layer.masksToBounds = YES;
    if ([CPAParseUtility userHasProfilePictures:[PFUser currentUser]]) {
        PFFile *imageFile = [[PFUser currentUser] objectForKey:@"profilePictureMedium"];
        [self.profileImageView setFile:imageFile];
        [self.profileImageView loadInBackground];
    } else {
        NSLog(@"no profile pictures");
        self.profileImageView.image = [UIImage imageNamed:@"profile"];
    }

    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0f]];
    [self.nameLabel setTextColor:[UIColor blackColor]];
    [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
    NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
    NSString *nameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self.nameLabel setText:nameString];
    
    self.jobSubtitleLabel = [[UILabel alloc] init];
    [self.jobSubtitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.jobSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.jobSubtitleLabel setTextColor:[UIColor grayColor]];
    [self.jobSubtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.jobSubtitleLabel setNumberOfLines:2];
    NSString *jobString = [[NSString alloc] init];
    if ([[PFUser currentUser] objectForKey:@"jobTitle"] && [[PFUser currentUser] objectForKey:@"company"]) {
        jobString = [NSString stringWithFormat:@"%@\n%@", [[PFUser currentUser] objectForKey:@"jobTitle"], [[PFUser currentUser] objectForKey:@"company"]];
    } else if ([[PFUser currentUser] objectForKey:@"industry"]) {
        jobString = [NSString stringWithFormat:@"%@", [[PFUser currentUser] objectForKey:@"industry"]];
    } else {
        jobString = @"";
    }
    [self.jobSubtitleLabel setText:jobString];
    
    // Buttons
    self.buttonBackgroundView = [[UIView alloc] init];
    self.buttonBackgroundView.backgroundColor = [UIColor lightGrayColor];
    
    self.myProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.myProfileButton setBackgroundColor:[UIColor whiteColor]];
    [self.myProfileButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"My Profile" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                   NSForegroundColorAttributeName : [UIColor blackColor],
                                                                                                                   NSKernAttributeName : @0.5}] forState:UIControlStateNormal];
    [self.myProfileButton addTarget:self
                             action:@selector(myProfileButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.myProfileButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.myProfileButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.myProfileButton.titleLabel.numberOfLines = 1;
    
    self.myFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.myFriendsButton setBackgroundColor:[UIColor whiteColor]];
    [self.myFriendsButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"My Friends" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                   NSForegroundColorAttributeName : [UIColor blackColor],
                                                                                                                   NSKernAttributeName : @0.5}] forState:UIControlStateNormal];
    [self.myFriendsButton addTarget:self
                             action:@selector(myFriendsButtonPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    self.myFriendsButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.myFriendsButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.myFriendsButton.titleLabel.numberOfLines = 1;
    
    self.logOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.logOutButton setBackgroundColor:[UIColor whiteColor]];
    [self.logOutButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Log Out" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                             NSForegroundColorAttributeName : [UIColor redColor],
                                                                                                             NSKernAttributeName : @0.5}] forState:UIControlStateNormal];
    [self.logOutButton addTarget:self
                          action:@selector(logOutButtonPressed:)
                forControlEvents:UIControlEventTouchUpInside];
    self.logOutButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.logOutButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.logOutButton.titleLabel.numberOfLines = 1;

    for (UIView *view in @[self.mainBackgroundView, self.nameBackgroundView, self.profileImageView, self.nameLabel, self.jobSubtitleLabel, self.buttonBackgroundView, self.myProfileButton, self.myFriendsButton, self.logOutButton]) {
        [self.view addSubview:view];
    }
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat profileImageSize = 75;
    CGFloat padding = 5;
    CGFloat buttonHeight = 30;
    
    self.mainBackgroundView.frame = CGRectMake(CGRectGetMinX(self.view.bounds) + padding,
                                               CGRectGetMinY(self.view.bounds) + padding,
                                               CGRectGetWidth(self.view.bounds) - (padding * 2),
                                               profileImageSize + 2);
    
    self.profileImageView.frame = CGRectMake(CGRectGetMinX(self.mainBackgroundView.frame) + 1,
                                             CGRectGetMinY(self.mainBackgroundView.frame) + 1,
                                             profileImageSize,
                                             profileImageSize);
    
    self.nameBackgroundView.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + 1,
                                               CGRectGetMinY(self.profileImageView.frame),
                                               CGRectGetWidth(self.mainBackgroundView.frame) - profileImageSize - (1 * 3),
                                               profileImageSize);
    // Get the total height of the labels
    CGSize maxNameLabelSize = CGSizeMake(CGRectGetWidth(self.nameBackgroundView.frame) - (padding * 2), CGFLOAT_MAX);
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:maxNameLabelSize];
    CGSize maxJobSubtitleLabelSize = CGSizeMake(CGRectGetWidth(self.nameBackgroundView.frame) - (padding * 2), CGFLOAT_MAX);
    CGSize jobSubtitleLabelSize = [self.jobSubtitleLabel sizeThatFits:maxJobSubtitleLabelSize];
    CGFloat totalLabelHeight = nameLabelSize.height + jobSubtitleLabelSize.height;
    
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + padding,
                                      CGRectGetMidY(self.profileImageView.frame) - totalLabelHeight / 2,
                                      nameLabelSize.width,
                                      nameLabelSize.height);
    
    self.jobSubtitleLabel.frame = CGRectMake(CGRectGetMaxX(self.profileImageView.frame) + padding,
                                             CGRectGetMaxY(self.nameLabel.frame),
                                             jobSubtitleLabelSize.width,
                                             jobSubtitleLabelSize.height);
    
    self.buttonBackgroundView.frame = CGRectMake(CGRectGetMinX(self.mainBackgroundView.frame),
                                                 CGRectGetMaxY(self.mainBackgroundView.frame) + 1,
                                                 CGRectGetWidth(self.mainBackgroundView.frame),
                                                 (buttonHeight * 3) + (1 * 4));
    
    self.myProfileButton.frame = CGRectMake(CGRectGetMinX(self.buttonBackgroundView.frame) + 1,
                                            CGRectGetMinY(self.buttonBackgroundView.frame) + 1,
                                            CGRectGetWidth(self.buttonBackgroundView.frame) - (1 * 2),
                                            buttonHeight);
    
    self.myFriendsButton.frame = CGRectMake(CGRectGetMinX(self.buttonBackgroundView.frame) + 1,
                                            CGRectGetMaxY(self.myProfileButton.frame) + 1,
                                            CGRectGetWidth(self.buttonBackgroundView.frame) - (1 * 2),
                                            buttonHeight);
    
    self.logOutButton.frame = CGRectMake(CGRectGetMinX(self.buttonBackgroundView.frame) + 1,
                                         CGRectGetMaxY(self.myFriendsButton.frame) + 1,
                                         CGRectGetWidth(self.buttonBackgroundView.frame) - (1 * 2),
                                         buttonHeight);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Actions

- (void)myFriendsButtonPressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuDidTapOnMyFriendsButton)]) {
        [self.delegate menuDidTapOnMyFriendsButton];
    }
}

- (void)myProfileButtonPressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuDidTapOnMyProfileButton)]) {
        [self.delegate menuDidTapOnMyProfileButton];
    }
}

- (void)logOutButtonPressed:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(menuDidTapOnLogOutButton)]) {
        [self.delegate menuDidTapOnLogOutButton];
    }
}

@end
