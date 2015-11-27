//
//  CPAJobTableViewCell.m
//  Referrall
//
//  Created by Collin Adler on 9/24/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAJobTableViewCell.h"

#import <ParseUI/ParseUI.h>

#import "CPASkillsCollectionViewCell.h"
#import "CPAJobSkillsCollectionViewLayout.h"

#import "CPAJob.h"
#import "CPAConstants.h"

@interface CPAJobTableViewCell () <UICollectionViewDataSource, UICollectionViewDelegate>

// Main background view
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

@property (nonatomic, strong) UILabel *skillsLabel;
@property (nonatomic, strong) UICollectionView *skillsCollectionView;

// Bottom buttons
@property (nonatomic, strong) UIButton *referButton;
@property (nonatomic, strong) UIButton *applyButton;
@property (nonatomic, strong) UIButton *rePostButton;

@end

@implementation CPAJobTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[CPAConstants lightGrayColor]];
        
        self.mainView = [[UIView alloc] init];
        self.mainView.backgroundColor = [UIColor whiteColor];
        self.mainView.layer.shadowOpacity = 0.15;
        self.mainView.layer.shadowOffset = CGSizeMake(2.0, 2.0);
        self.mainView.layer.shadowRadius = 1.0;
        [self.contentView addSubview:self.mainView];
        
        self.userImageView  = [[PFImageView alloc] init];
        [self.userImageView setBackgroundColor:[UIColor clearColor]];
        [self.userImageView setOpaque:YES];
        [self.mainView addSubview:self.userImageView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5f]];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.mainView addSubview:self.nameLabel];
        
        self.userSubtitleLabel = [[UILabel alloc] init];
        [self.userSubtitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.userSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.5f]];
        [self.userSubtitleLabel setTextColor:[UIColor grayColor]];
        [self.userSubtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.userSubtitleLabel setNumberOfLines:2];
        [self.mainView addSubview:self.userSubtitleLabel];

        self.titleView = [[UIView alloc] init];
        self.titleView.backgroundColor = [UIColor whiteColor];
        self.titleView.alpha = 0.5;
        self.titleView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.titleView.layer.borderWidth = 0.5f;
        self.titleView.layer.cornerRadius = 2;
        [self.mainView addSubview:self.titleView];

        self.titleLabel = [[UILabel alloc] init];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.mainView addSubview:self.titleLabel];

        self.subtitleLabel = [[UILabel alloc] init];
        [self.subtitleLabel setBackgroundColor:[UIColor clearColor]];
        self.subtitleLabel.adjustsFontSizeToFitWidth = YES;
        self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
        [self.mainView addSubview:self.subtitleLabel];

        self.descriptionDivider = [[UIView alloc] init];
        self.descriptionDivider.backgroundColor = [UIColor lightGrayColor];
        [self.mainView addSubview:self.descriptionDivider];
        
        self.descriptionTitleLabel = [[UILabel alloc] init];
        [self.descriptionTitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.descriptionTitleLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Description" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                              NSForegroundColorAttributeName : [UIColor grayColor]}]];
        [self.mainView addSubview:self.descriptionTitleLabel];
        
        self.descriptionLabel = [[UILabel alloc] init];
        [self.descriptionLabel setBackgroundColor:[UIColor clearColor]];
        self.descriptionLabel.numberOfLines = 3;
        [self.descriptionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.mainView addSubview:self.descriptionLabel];
        
        // Skills collection view
        self.skillsLabel = [[UILabel alloc] init];
        [self.skillsLabel setBackgroundColor:[UIColor clearColor]];
        [self.skillsLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Skills" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                            NSForegroundColorAttributeName : [UIColor grayColor]}]];
        [self.mainView addSubview:self.skillsLabel];
        
        CPAJobSkillsCollectionViewLayout *skillsFlowLayout = [[CPAJobSkillsCollectionViewLayout alloc] init]; // subclass standard flow to make maximum size between cells
        skillsFlowLayout.itemSize = CGSizeMake(0, 0); // We resize these at layout
        skillsFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        skillsFlowLayout.minimumInteritemSpacing = 0;
        
        self.skillsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:skillsFlowLayout];
        self.skillsCollectionView.showsHorizontalScrollIndicator = NO;
        self.skillsCollectionView.backgroundColor = [UIColor clearColor];
        self.skillsCollectionView.alwaysBounceHorizontal = YES;
        self.skillsCollectionView.dataSource = self;
        self.skillsCollectionView.delegate = self;
        [self.mainView addSubview:self.skillsCollectionView];
        
        // Bottom buttons
        self.referButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.referButton setBackgroundColor:[CPAConstants skyBlueColor]];
        [self.referButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"REFER" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.5f],
                                                                                                                  NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                                  NSKernAttributeName : @2.0}] forState:UIControlStateNormal];
        self.referButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.referButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.referButton.titleLabel.numberOfLines = 1;
        self.referButton.alpha = 0.5;
        [self.mainView addSubview:self.referButton];

        self.applyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.applyButton setBackgroundColor:[CPAConstants skyBlueColor]];
        [self.applyButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"APPLY" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.5f],
                                                                                                              NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                              NSKernAttributeName : @2.0}] forState:UIControlStateNormal];
        self.applyButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.applyButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.applyButton.titleLabel.numberOfLines = 1;
        self.applyButton.alpha = 0.5;
        [self.mainView addSubview:self.applyButton];

        self.rePostButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rePostButton setBackgroundColor:[CPAConstants skyBlueColor]];
        [self.rePostButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"RE-POST" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.5f],
                                                                                                              NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                              NSKernAttributeName : @2.0}] forState:UIControlStateNormal];
        self.rePostButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.rePostButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.rePostButton.titleLabel.numberOfLines = 1;
        self.rePostButton.alpha = 0.5;
        [self.mainView addSubview:self.rePostButton];
        
        // Register cell classes
        [self.skillsCollectionView registerClass:[CPASkillsCollectionViewCell class] forCellWithReuseIdentifier:@"skillCell"];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat padding = 5;
    CGFloat cellPadding = 7.5;
    CGFloat userImageViewSize = 40.f;
    
    self.mainView.frame = CGRectMake(cellPadding,
                                     cellPadding,
                                     CGRectGetWidth(self.bounds) - (cellPadding * 2),
                                     0); // we will resize it once all the views are layed out
    
    // Main view subviews
    self.userImageView.frame = CGRectMake(CGRectGetMinX(self.bounds) + padding,
                                          CGRectGetMinY(self.bounds) + padding,
                                          userImageViewSize,
                                          userImageViewSize);
    
    CGSize maxNameLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - userImageViewSize - (padding * 3), CGFLOAT_MAX);
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
                                       CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                       titleLabelSize.height);
    
    self.subtitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                          CGRectGetMaxY(self.titleLabel.frame),
                                          CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                          subtitleLabelSize.height);
    
    self.descriptionDivider.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                               CGRectGetMaxY(self.titleView.frame) + padding,
                                               CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                               0.5);
    
    self.descriptionTitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                        CGRectGetMaxY(self.descriptionDivider.frame) + padding,
                                        CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                        15);
    
    CGSize maxDescriptionLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (padding * 2), CGFLOAT_MAX);
    CGSize descriptionLabelSize = [self.descriptionLabel sizeThatFits:maxDescriptionLabelSize];
    self.descriptionLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                             CGRectGetMaxY(self.descriptionTitleLabel.frame),
                                             CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                             descriptionLabelSize.height);

    self.skillsLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                        CGRectGetMaxY(self.descriptionLabel.frame) + padding,
                                        CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                        15);
    
    // Layout collection view
    // At layout, calc the size of each cell. Fit as many as possible on each row
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.skillsCollectionView.collectionViewLayout;
    CGFloat width = CGRectGetWidth(self.mainView.frame) - (padding * 2);
    CGFloat cellWidth = (width - flowLayout.minimumInteritemSpacing * 3) / 4;
    flowLayout.itemSize = CGSizeMake(cellWidth, 27);
    self.skillsCollectionView.frame = CGRectMake(padding,
                                                 CGRectGetMaxY(self.skillsLabel.frame) + padding / 2,
                                                 CGRectGetWidth(self.mainView.frame) - (padding * 2),
                                                 flowLayout.itemSize.height);
    
    CGFloat buttonWidth = (CGRectGetWidth(self.mainView.frame) - 8) / 3;
    CGFloat buttonHeight = 22.5;
    self.referButton.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + 2,
                                        CGRectGetMaxY(self.skillsCollectionView.frame) + padding,
                                        buttonWidth,
                                        buttonHeight);

    self.applyButton.frame = CGRectMake(CGRectGetMaxX(self.referButton.frame) + 2,
                                        CGRectGetMaxY(self.skillsCollectionView.frame) + padding,
                                        buttonWidth,
                                        buttonHeight);

    self.rePostButton.frame = CGRectMake(CGRectGetMaxX(self.applyButton.frame) + 2,
                                         CGRectGetMaxY(self.skillsCollectionView.frame) + padding,
                                         buttonWidth,
                                         buttonHeight);

    // Resize the mainview to contain its subviews
    CGFloat newMainViewHeight = [self maxHeightForMainViewToFitSubviews:self.mainView];
    self.mainView.frame = CGRectMake(cellPadding,
                                     cellPadding,
                                     CGRectGetWidth(self.bounds) - (cellPadding * 2),
                                     newMainViewHeight + 2);
    // Create a rect for the shadow
    [self.mainView.layer setShadowPath:[UIBezierPath bezierPathWithRect:self.mainView.bounds].CGPath]; // need to add a shadow path or else scrolling is slow

}

#pragma mark - Overrides

- (void)setJob:(CPAJob *)job {
    _job = job;

    // Set the user image view
    self.userImageView.image = [UIImage imageNamed:@"profile"];
    if ([self.job.user objectForKey:@"profilePictureSmall"]) {
        self.userImageView.file = self.job.user[@"profilePictureSmall"];
        [self.userImageView loadInBackground];
    }
    
    // Set name
    NSString *firstName = [self.job.user objectForKey:@"firstName"];
    NSString *lastName = [self.job.user objectForKey:@"lastName"];
    NSString *fullNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self.nameLabel setText:fullNameString];
    
    // Set user name
    NSString *jobString = [[NSString alloc] init];
    if ([self.job.user objectForKey:@"jobTitle"] && [self.job.user objectForKey:@"company"]) {
        jobString = [NSString stringWithFormat:@"%@ at %@", [self.job.user objectForKey:@"jobTitle"], [self.job.user objectForKey:@"company"]];
    } else if ([self.job.user objectForKey:@"industry"]) {
        jobString = [NSString stringWithFormat:@"%@", [self.job.user objectForKey:@"industry"]];
    } else {
        jobString = @"";
    }
    [self.userSubtitleLabel setText:jobString];
    
    // Set job title with format [Job Title] at [Company Title]
    NSMutableAttributedString *jobTitleString = [[NSMutableAttributedString alloc] initWithString:self.job.title attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                              NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:@" at " attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                              NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [jobTitleString appendAttributedString:atString];
    NSMutableAttributedString *companyString = [[NSMutableAttributedString alloc] initWithString:self.job.company attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor blackColor]}];
    [jobTitleString appendAttributedString:companyString];
    [self.titleLabel setAttributedText:jobTitleString];
    
    // Set subtitle with format [Job Location] • [Industry Title]
    NSMutableAttributedString *locationString = [[NSMutableAttributedString alloc] initWithString:self.job.locationString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                              NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSMutableAttributedString *dotString = [[NSMutableAttributedString alloc] initWithString:@" • " attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:8.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [locationString appendAttributedString:dotString];
    NSMutableAttributedString *industryString = [[NSMutableAttributedString alloc] initWithString:self.job.industry attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                               NSForegroundColorAttributeName : [UIColor blackColor]}];
    [locationString appendAttributedString:industryString];
    [self.subtitleLabel setAttributedText:locationString];

    // Set description
    NSString *descriptionString = self.job.jobDescription;
    [self.descriptionLabel setAttributedText:[[NSAttributedString alloc] initWithString:descriptionString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                         NSForegroundColorAttributeName : [UIColor blackColor]}]];
}

#pragma mark - UICollectionView delegate and data source

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPASkillsCollectionViewCell *cell = (CPASkillsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"skillCell" forIndexPath:indexPath];
    cell.skillString = self.job.skills[indexPath.row];
    return cell;
}

// There will always only be 1 section, regardless of if its the events or posts
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.job.skills.count;
}

#pragma mark - UIView sizing

-(CGFloat)maxHeightForMainViewToFitSubviews:(UIView *)mainView {

    float height = 0;
    for (UIView *v in [mainView subviews]) {
        float fh = v.frame.origin.y + v.frame.size.height;
        height = MAX(fh, height);
    }
    return height;
}

#pragma mark - Height helper method

+ (CGFloat)heightForJobCell:(CPAJob *)job width:(CGFloat)width {
    // Make a cell
    CPAJobTableViewCell *layoutCell = [[CPAJobTableViewCell alloc] init];
    layoutCell.job = job;
    layoutCell.bounds = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    return CGRectGetMaxY(layoutCell.mainView.frame);
}

@end
