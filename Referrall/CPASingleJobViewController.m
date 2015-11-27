//
//  CPASingleJobViewController.m
//  Referrall
//
//  Created by Collin Adler on 11/27/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import "CPASingleJobViewController.h"
#import <ParseUI/ParseUI.h>

#import "CPAJob.h"
#import "CPAConstants.h"

@interface CPASingleJobViewController ()

// Main scroll view
@property (nonatomic, strong) UIScrollView *mainScrollView;

@property (nonatomic, strong) UIView *mainView;

@property (nonatomic, strong) PFImageView *userImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userSubtitleLabel;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIView *descriptionDivider;
@property (nonatomic, strong) UILabel *descriptionTitleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

@end

@implementation CPASingleJobViewController

- (instancetype)initWithJob:(CPAJob *)job {
    self = [super init];
    if (self) {
        self.job = job;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [CPAConstants lightGrayColor];

    self.mainScrollView = [[UIScrollView alloc] init];
    self.mainScrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), 0);
    [self.mainScrollView setShowsVerticalScrollIndicator:NO];
    [self.mainScrollView setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.mainScrollView];
    
    self.mainView = [[UIView alloc] init];
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.mainView.layer.shadowOpacity = 0.15;
    self.mainView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
    self.mainView.layer.shadowRadius = 1.0;
    [self.mainScrollView addSubview:self.mainView];
    
    self.userImageView  = [[PFImageView alloc] init];
    [self.userImageView setBackgroundColor:[UIColor clearColor]];
    [self.userImageView setOpaque:YES];
    self.userImageView.image = [UIImage imageNamed:@"profile"];
    if ([self.job.user objectForKey:@"profilePictureSmall"]) {
        self.userImageView.file = self.job.user[@"profilePictureSmall"];
        [self.userImageView loadInBackground];
    }
    
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5f]];
    [self.nameLabel setTextColor:[UIColor blackColor]];
    [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    NSString *firstName = [self.job.user objectForKey:@"firstName"];
    NSString *lastName = [self.job.user objectForKey:@"lastName"];
    NSString *fullNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self.nameLabel setText:fullNameString];
    
    self.userSubtitleLabel = [[UILabel alloc] init];
    [self.userSubtitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.userSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.5f]];
    [self.userSubtitleLabel setTextColor:[UIColor grayColor]];
    [self.userSubtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.userSubtitleLabel setNumberOfLines:2];
    NSString *jobString = [[NSString alloc] init];
    if ([self.job.user objectForKey:@"jobTitle"] && [self.job.user objectForKey:@"company"]) {
        jobString = [NSString stringWithFormat:@"%@ at %@", [self.job.user objectForKey:@"jobTitle"], [self.job.user objectForKey:@"company"]];
    } else if ([self.job.user objectForKey:@"industry"]) {
        jobString = [NSString stringWithFormat:@"%@", [self.job.user objectForKey:@"industry"]];
    } else {
        jobString = @"";
    }
    [self.userSubtitleLabel setText:jobString];
    
    self.titleView = [[UIView alloc] init];
    self.titleView.backgroundColor = [UIColor whiteColor];
    self.titleView.alpha = 0.5;
    self.titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.titleView.layer.borderWidth = 0.5f;
    self.titleView.layer.cornerRadius = 2;
    
    self.titleLabel = [[UILabel alloc] init];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *jobTitleString = [[NSMutableAttributedString alloc] initWithString:self.job.title attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                              NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:@" at " attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [jobTitleString appendAttributedString:atString];
    NSMutableAttributedString *companyString = [[NSMutableAttributedString alloc] initWithString:self.job.company attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                               NSForegroundColorAttributeName : [UIColor blackColor]}];
    [jobTitleString appendAttributedString:companyString];
    [self.titleLabel setAttributedText:jobTitleString];
    
    self.subtitleLabel = [[UILabel alloc] init];
    [self.subtitleLabel setBackgroundColor:[UIColor clearColor]];
    self.subtitleLabel.adjustsFontSizeToFitWidth = YES;
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *locationString = [[NSMutableAttributedString alloc] initWithString:self.job.locationString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                                       NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSMutableAttributedString *dotString = [[NSMutableAttributedString alloc] initWithString:@" • " attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:8.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [locationString appendAttributedString:dotString];
    NSMutableAttributedString *industryString = [[NSMutableAttributedString alloc] initWithString:self.job.industry attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                                 NSForegroundColorAttributeName : [UIColor blackColor]}];
    [locationString appendAttributedString:industryString];
    [self.subtitleLabel setAttributedText:locationString];
    
    self.descriptionDivider = [[UIView alloc] init];
    self.descriptionDivider.backgroundColor = [UIColor lightGrayColor];
    
    self.descriptionTitleLabel = [[UILabel alloc] init];
    [self.descriptionTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.descriptionTitleLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Description" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                         NSForegroundColorAttributeName : [UIColor grayColor]}]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    [self.descriptionLabel setBackgroundColor:[UIColor clearColor]];
    self.descriptionLabel.numberOfLines = 0;
    [self.descriptionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    NSString *descriptionString = self.job.jobDescription;
    [self.descriptionLabel setAttributedText:[[NSAttributedString alloc] initWithString:descriptionString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                       NSForegroundColorAttributeName : [UIColor blackColor]}]];

    for (UIView *view in @[self.userImageView, self.nameLabel, self.userSubtitleLabel, self.titleView, self.titleLabel, self.subtitleLabel, self.descriptionDivider, self.descriptionTitleLabel, self.descriptionLabel]) {
        [self.mainView addSubview:view];
    }
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat cellPadding = 7.5;
    CGFloat padding = 5;
    CGFloat userImageViewSize = 40.f;
    
    self.mainScrollView.frame = self.view.bounds;
    
    self.mainView.frame = CGRectMake(cellPadding,
                                     cellPadding,
                                     CGRectGetWidth(self.view.bounds) - (cellPadding * 2),
                                     CGRectGetHeight(self.view.bounds) - (cellPadding * 2));
    
    // Main view subviews
    self.userImageView.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                          CGRectGetMinY(self.mainView.bounds) + padding,
                                          userImageViewSize,
                                          userImageViewSize);
    
    CGSize maxNameLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds) - userImageViewSize - (padding * 3), CGFLOAT_MAX);
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:maxNameLabelSize];
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.userImageView.frame) + padding,
                                      CGRectGetMinY(self.userImageView.frame),
                                      nameLabelSize.width,
                                      nameLabelSize.height);
    
    CGSize maxUserJobLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - userImageViewSize - (padding * 3), CGFLOAT_MAX);
    CGSize userJobLabelSize = [self.userSubtitleLabel sizeThatFits:maxUserJobLabelSize];
    self.userSubtitleLabel.frame = CGRectMake(CGRectGetMaxX(self.userImageView.frame) + padding,
                                              CGRectGetMaxY(self.nameLabel.frame),
                                              userJobLabelSize.width,
                                              userJobLabelSize.height);
    
    // Size the label heights needed first
    CGSize maxTitleLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (padding * 2), CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:maxTitleLabelSize];
    CGSize maxSubtitleLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (padding * 2), CGFLOAT_MAX);
    CGSize subtitleLabelSize = [self.subtitleLabel sizeThatFits:maxSubtitleLabelSize];
    CGFloat totalTitleAndSubtitleHeight = titleLabelSize.height + subtitleLabelSize.height;
    
    self.titleView.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                      CGRectGetMaxY(self.userImageView.frame) + padding,
                                      CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                      totalTitleAndSubtitleHeight + padding);
    
    self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                       CGRectGetMinY(self.titleView.frame) + padding / 2,
                                       CGRectGetWidth(self.mainView.bounds) - (padding * 2),
                                       titleLabelSize.height);
    
    self.subtitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                          CGRectGetMaxY(self.titleLabel.frame),
                                          CGRectGetWidth(self.mainView.bounds) - (padding * 2),
                                          subtitleLabelSize.height);
    
    self.descriptionDivider.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                               CGRectGetMaxY(self.titleView.frame) + padding,
                                               CGRectGetWidth(self.mainView.bounds) - (padding * 2),
                                               0.5);
    
    self.descriptionTitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                                  CGRectGetMaxY(self.descriptionDivider.frame) + padding,
                                                  CGRectGetWidth(self.mainView.bounds) - (padding * 2),
                                                  15);
    
    CGSize maxDescriptionLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (padding * 2), CGFLOAT_MAX);
    CGSize descriptionLabelSize = [self.descriptionLabel sizeThatFits:maxDescriptionLabelSize];
    self.descriptionLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                             CGRectGetMaxY(self.descriptionTitleLabel.frame),
                                             CGRectGetWidth(self.mainView.bounds) - (padding * 2),
                                             descriptionLabelSize.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
