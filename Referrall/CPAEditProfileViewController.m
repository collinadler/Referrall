//
//  CPAEditProfileViewController.m
//  Referrall
//
//  Created by Collin Adler on 8/25/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <Parse/Parse.h>

#import "CPAEditProfileViewController.h"
#import "CPAAddFriendsViewController.h"

#import "CPAInsetTextField.h"
#import "CPASkillsCollectionViewCell.h"
#import "CPAButtonScrollView.h"

#import "CPASkills.h"
#import "CPAConstants.h"

typedef NS_ENUM(NSInteger, CPAEditProfileViewControllerState) {
    CPAEditProfileViewControllerStateText,
    CPAEditProfileViewControllerStateSkills
};

@interface CPAEditProfileViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, CPAButtonScrollViewDelegate>

@property (nonatomic, strong) UIImage *profileImage;

// Main scroll view
@property (nonatomic, strong) UIScrollView *scrollView;

// Two view states - one with textfield's visible, and another with skills collection view visible
@property (nonatomic, assign) CPAEditProfileViewControllerState state;

// Main views
@property (nonatomic, strong) UIView *backgroundProfileView;
@property (nonatomic, strong) UIImageView *profileImageView;

@property (nonatomic, strong) CPAInsetTextField *firstNameField;
@property (nonatomic, strong) CPAInsetTextField *lastNameField;
@property (nonatomic, strong) UIView *nameBackgroundView;

@property (nonatomic, strong) CPAInsetTextField *companyField;
@property (nonatomic, strong) CPAInsetTextField *titleField;
@property (nonatomic, strong) CPAInsetTextField *industryField;
@property (nonatomic, strong) CPAInsetTextField *cityField;
@property (nonatomic, strong) CPAInsetTextField *stateField;
@property (nonatomic, strong) UIView *mainFieldBackgroundView;

@property (nonatomic, strong) UIPickerView *industryPickerView;
@property (nonatomic, strong) UIPickerView *statePickerView;

@property (nonatomic, strong) UICollectionView *skillsCollectionView;

@property (nonatomic, strong) UITapGestureRecognizer *mainViewTap;

@property (nonatomic, strong) UILabel *tapSkillsLabel; // Initially hidden until user progresses to skills state
@property (nonatomic, strong) CPAButtonScrollView *buttonScrollView; // Hidden until user progresses to skills state
@property (nonatomic, strong) UIView *skillsListView;
// Subviews of skillsListView
@property (nonatomic, strong) UILabel *skillsLabel;
@property (nonatomic, strong) UILabel *skillsListLabel;

// Data properties
@property (nonatomic, strong) CPASkills *skills;
@property (nonatomic, strong) NSArray *skillsArray; // this is what our colleciton view will pull from
@property (nonatomic, strong) NSMutableArray *userSkillsMutableArray; // the user's current skills

@end

@implementation CPAEditProfileViewController

- (instancetype)initWithImage:(UIImage *)profileImage {
    self = [super init];
    if (self) {
        
        self.state = CPAEditProfileViewControllerStateText;
        
        self.profileImage = [[UIImage alloc] init];
        if (profileImage) {
            _profileImage = profileImage;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.skillsArray = [[NSArray alloc] init];
    self.userSkillsMutableArray = [[NSMutableArray alloc] init];
    if (self.skillsArray) {
        self.skills = [[CPASkills alloc] init];
    }
    
    // Reset nav bar properties
    self.navigationController.navigationBar.translucent= NO; // makes views show up beneath nav bar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;        
    }
    self.title = @"Add Work Details";
    
    UIBarButtonItem *nextBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Next", @"Go to next button")
                                                                     style:UIBarButtonItemStyleDone
                                                                    target:self
                                                                    action:@selector(nextBarButtonPressed:)];
    self.navigationItem.rightBarButtonItem = nextBarButton;
    
    // Create the background view
    UIImage *backgroundImage = [UIImage imageNamed:@"onboard"];
    UIImageView *backgroundImageView;
    
    // create the background image view and set it to aspect fill so it isn't skewed
    if (backgroundImage) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [backgroundImageView setImage:backgroundImage];
        [self.view addSubview:backgroundImageView];
    }
    
    // as long as the shouldMaskBackground setting hasn't been set to NO, we want to
    // create a partially opaque view and add it on top of the image view, so that it
    // darkens it a bit for better contrast
    UIView *backgroundMaskView;
    backgroundMaskView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundMaskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.6f];
    [self.view addSubview:backgroundMaskView];
    
    // send the background image view to the back if we have one
    if (backgroundImageView) {
        [self.view sendSubviewToBack:backgroundImageView];
    }
    
    self.scrollView = [[UIScrollView alloc] init];
    [self.view addSubview:self.scrollView];
    
    self.backgroundProfileView = [[UIView alloc] init];
    self.backgroundProfileView.backgroundColor = [UIColor lightGrayColor];
    
    self.profileImageView = [[UIImageView alloc] initWithImage:self.profileImage];
    
    self.firstNameField = [[CPAInsetTextField alloc] init];
    self.firstNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                      NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.firstNameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.firstNameField setTextColor:[CPAConstants skyBlueColor]];
    self.firstNameField.backgroundColor = [UIColor whiteColor];
    self.firstNameField.delegate = self;
    if ([[PFUser currentUser] objectForKey:@"firstName"]) {
        self.firstNameField.attributedText = [[NSAttributedString alloc] initWithString:[[PFUser currentUser] objectForKey:@"firstName"] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f],
                                                                                                                          NSForegroundColorAttributeName : [CPAConstants skyBlueColor]}];
    }
    
    self.lastNameField = [[CPAInsetTextField alloc] init];
    self.lastNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                      NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.lastNameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.lastNameField setTextColor:[CPAConstants skyBlueColor]];
    self.lastNameField.backgroundColor = [UIColor whiteColor];
    self.lastNameField.delegate = self;
    if ([[PFUser currentUser] objectForKey:@"lastName"]) {
        self.lastNameField.attributedText = [[NSAttributedString alloc] initWithString:[[PFUser currentUser] objectForKey:@"lastName"] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0f],
                                                                                                                                                      NSForegroundColorAttributeName : [CPAConstants skyBlueColor]}];
    }
    
    self.nameBackgroundView = [[UIView alloc] init];
    self.nameBackgroundView.backgroundColor = [UIColor lightGrayColor];
    
    self.companyField = [[CPAInsetTextField alloc] init];
    self.companyField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Company (optional)" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                    NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.companyField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.companyField setTextColor:[CPAConstants skyBlueColor]];
    self.companyField.backgroundColor = [UIColor whiteColor];
    self.companyField.delegate = self;
    
    self.titleField = [[CPAInsetTextField alloc] init];
    self.titleField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Title (optional)" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.titleField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.titleField setTextColor:[CPAConstants skyBlueColor]];
    self.titleField.backgroundColor = [UIColor whiteColor];
    self.titleField.delegate = self;
    
    self.industryField = [[CPAInsetTextField alloc] init];
    self.industryField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Industry" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                             NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.industryField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.industryField setTextColor:[CPAConstants skyBlueColor]];
    self.industryField.backgroundColor = [UIColor whiteColor];
    self.industryField.delegate = self;

    self.cityField = [[CPAInsetTextField alloc] init];
    self.cityField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"City (optional)" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.cityField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.cityField setTextColor:[CPAConstants skyBlueColor]];
    self.cityField.backgroundColor = [UIColor whiteColor];
    self.cityField.delegate = self;
    
    self.stateField = [[CPAInsetTextField alloc] init];
    self.stateField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"State (optional)" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                   NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.stateField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.stateField setTextColor:[CPAConstants skyBlueColor]];
    self.stateField.backgroundColor = [UIColor whiteColor];
    self.stateField.delegate = self;
    
    self.mainFieldBackgroundView = [[UIView alloc] init];
    self.mainFieldBackgroundView.backgroundColor = [UIColor lightGrayColor];

    self.industryPickerView = [[UIPickerView alloc] init];
    self.industryPickerView.delegate = self;
    self.industryPickerView.showsSelectionIndicator = YES;
    self.industryPickerView.backgroundColor = [CPAConstants skyBlueColor];
    self.industryPickerView.hidden = YES;
    
    self.statePickerView = [[UIPickerView alloc] init];
    self.statePickerView.delegate = self;
    self.statePickerView.showsSelectionIndicator = YES;
    self.statePickerView.backgroundColor = [CPAConstants skyBlueColor];
    self.statePickerView.hidden = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    
    self.skillsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.skillsCollectionView.backgroundColor = [UIColor clearColor];
    self.skillsCollectionView.dataSource = self;
    self.skillsCollectionView.delegate = self;
    
    self.tapSkillsLabel = [[UILabel alloc] init];
    self.tapSkillsLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Tap Skills Below To Add To Your Profile" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13.0f],
                                                                                                                                            NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.tapSkillsLabel.adjustsFontSizeToFitWidth = YES;
    self.tapSkillsLabel.textAlignment = NSTextAlignmentCenter;
    self.tapSkillsLabel.backgroundColor = [UIColor whiteColor];
    self.tapSkillsLabel.hidden = YES;

    self.buttonScrollView = [[CPAButtonScrollView alloc] init];
    self.buttonScrollView.buttonDelegate = self;
    self.buttonScrollView.hidden = YES;
    
    self.skillsListView = [[UIView alloc] init];
    self.skillsListView.backgroundColor = [UIColor whiteColor];
    
    // Register cell classes
    [self.skillsCollectionView registerClass:[CPASkillsCollectionViewCell class] forCellWithReuseIdentifier:@"skillCell"];
    
    self.mainViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainViewTapFired:)];
    [self.mainViewTap setCancelsTouchesInView:NO];
    [self.view addGestureRecognizer:self.mainViewTap];
    
    for (UIView *view in @[self.backgroundProfileView, self.profileImageView, self.nameBackgroundView, self.firstNameField, self.lastNameField, self.mainFieldBackgroundView, self.companyField, self.titleField, self.industryField, self.cityField, self.stateField, self.industryPickerView, self.statePickerView, self.skillsCollectionView, self.tapSkillsLabel, self.buttonScrollView, self.skillsListView]) {
        [self.scrollView addSubview:view];
//        view.layer.borderColor = [UIColor redColor].CGColor;
//        view.layer.borderWidth = 1;
    }
    
    // Subviews of skills list view
    self.skillsLabel = [[UILabel alloc] init];
    self.skillsLabel.backgroundColor = [UIColor clearColor];
    self.skillsLabel.adjustsFontSizeToFitWidth = YES;
    self.skillsLabel.textAlignment = NSTextAlignmentCenter;
    self.skillsLabel.attributedText = [[NSAttributedString alloc] initWithString:@"My Skills"
                                                                      attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f],
                                                                                   NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.skillsListView addSubview:self.skillsLabel];
    
    self.skillsListLabel = [[UILabel alloc] init];
    self.skillsListLabel.backgroundColor = [UIColor clearColor];
    self.skillsListLabel.textColor = [CPAConstants skyBlueColor];
    self.skillsListLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    self.skillsListLabel.textAlignment = NSTextAlignmentCenter;
    self.skillsListLabel.adjustsFontSizeToFitWidth = YES;
    self.skillsListLabel.numberOfLines = 6; // make this span multiple lines if necessary
    [self.skillsListView addSubview:self.skillsListLabel];
}

- (void)updateViewContent {
    switch (self.state) {
        case CPAEditProfileViewControllerStateText: {
            self.navigationItem.leftBarButtonItem = nil;
            self.tapSkillsLabel.hidden = YES;
            self.buttonScrollView.hidden = YES;
            self.title = @"Add Work Details";
        } break;
        case CPAEditProfileViewControllerStateSkills: {
            UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Go back button")
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(backBarButtonPressed:)];
            self.navigationItem.leftBarButtonItem = backBarButton;
            self.title = @"Add Career Skills";

            self.tapSkillsLabel.hidden = NO;
            self.buttonScrollView.hidden = NO;
            self.buttonScrollView.buttonTitles = self.skills.skillTitles;
        } break;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    
    CGFloat padding = 5;
    CGFloat fieldBorder = 1;
    CGFloat nameTextFieldHeight = 35;
    CGFloat profileImageViewSize = (nameTextFieldHeight * 2) + (fieldBorder * 3);
    CGFloat pickerViewHeight = 150;
    
    self.profileImageView.frame = CGRectMake(padding + fieldBorder,
                                             padding + fieldBorder,
                                             profileImageViewSize - (fieldBorder * 2),
                                             profileImageViewSize - (fieldBorder * 2));
    
    CGFloat nameBackgroundViewWidth = CGRectGetWidth(self.view.bounds) - CGRectGetWidth(self.backgroundProfileView.frame) - (padding * 3);
    self.nameBackgroundView.frame = CGRectMake(CGRectGetMaxX(self.backgroundProfileView.frame) + padding,
                                               padding,
                                               nameBackgroundViewWidth,
                                               CGRectGetHeight(self.backgroundProfileView.frame));
    
    self.firstNameField.frame = CGRectMake(CGRectGetMinX(self.nameBackgroundView.frame) + fieldBorder,
                                           CGRectGetMinY(self.nameBackgroundView.frame) + fieldBorder,
                                           CGRectGetWidth(self.nameBackgroundView.frame) - (fieldBorder * 2),
                                           nameTextFieldHeight);
    self.lastNameField.frame = CGRectMake(CGRectGetMinX(self.nameBackgroundView.frame) + fieldBorder,
                                          CGRectGetMaxY(self.firstNameField.frame) + fieldBorder,
                                          CGRectGetWidth(self.nameBackgroundView.frame) - (fieldBorder * 2),
                                          nameTextFieldHeight);
    
    self.industryPickerView.frame = CGRectMake(0,
                                               CGRectGetMaxY(self.view.bounds) - pickerViewHeight,
                                               CGRectGetWidth(self.view.bounds),
                                               pickerViewHeight);
    
    self.statePickerView.frame = CGRectMake(0,
                                               CGRectGetMaxY(self.view.bounds) - pickerViewHeight,
                                               CGRectGetWidth(self.view.bounds),
                                               pickerViewHeight);

    [self layoutViews];

}

- (void)layoutViews {
    
    CGFloat padding = 5;
    CGFloat fieldBorder = 1;
    CGFloat nameTextFieldHeight = 35; // this is from the viewwilllayoutsubviews, and is needed to size the skillsListView
    CGFloat profileImageViewSize = (nameTextFieldHeight * 2) + (fieldBorder * 3);
    CGFloat textFieldHeight = 30;
    CGFloat textFieldWidth = CGRectGetWidth(self.view.bounds) - (padding * 2) - (fieldBorder * 2);
    CGFloat skillsLabelHeight = 20;
    CGFloat backgroundProfileViewWidth = 0.f;
    CGFloat mainBackgroundViewHeight = 0.f;
    CGFloat skillsListViewY = 0.f;
    CGFloat minSkillsListViewHeight = (nameTextFieldHeight * 2) + fieldBorder;
    
    switch (self.state) {
        case CPAEditProfileViewControllerStateText: {
            mainBackgroundViewHeight = textFieldHeight * 4 + (fieldBorder * 5);
            skillsListViewY = CGRectGetMinY(self.view.bounds) - MAX(CGRectGetHeight(self.skillsListView.frame), minSkillsListViewHeight);
            backgroundProfileViewWidth = profileImageViewSize;
        } break;
        case CPAEditProfileViewControllerStateSkills: {
            mainBackgroundViewHeight = textFieldHeight * 2 + (fieldBorder * 3);
            skillsListViewY = CGRectGetMinY(self.firstNameField.frame);
            backgroundProfileViewWidth = textFieldWidth;
        } break;
    }
    
    self.backgroundProfileView.frame = CGRectMake(padding,
                                                  padding,
                                                  backgroundProfileViewWidth,
                                                  profileImageViewSize);

    self.skillsListView.frame = CGRectMake(padding + fieldBorder,
                                           skillsListViewY,
                                           textFieldWidth,
                                           minSkillsListViewHeight); // we will resize this after sizing its containing views
    
    self.skillsLabel.frame = CGRectMake(CGRectGetMinX(self.skillsListView.bounds),
                                        CGRectGetMinY(self.skillsListView.bounds),
                                        CGRectGetWidth(self.skillsListView.bounds),
                                        skillsLabelHeight);
    
    CGSize maxSkillsListLabelSize = CGSizeMake(CGRectGetWidth(self.skillsListView.bounds) - padding * 2, CGFLOAT_MAX);
    CGSize skillsListLabelSize = [self.skillsListLabel sizeThatFits:maxSkillsListLabelSize];
    self.skillsListLabel.frame = CGRectMake(CGRectGetMinX(self.skillsListView.bounds) + padding,
                                            CGRectGetMaxY(self.skillsLabel.frame),
                                            CGRectGetWidth(self.skillsListView.bounds) - padding * 2,
                                            skillsListLabelSize.height + padding / 2);
    
    // Resize the skills view to contain its subviews
    CGFloat newSkillsViewHeight = [self maxHeightForSkillsViewToFitSubviews:self.skillsListView];
    self.skillsListView.frame = CGRectMake(padding + fieldBorder,
                                           skillsListViewY,
                                           textFieldWidth,
                                           MAX(newSkillsViewHeight + padding, minSkillsListViewHeight));

    // Handling layout of main background view special since its dependent on the size of the skills list view
    switch (self.state) {
        case CPAEditProfileViewControllerStateText: {
            self.mainFieldBackgroundView.frame = CGRectMake(padding,
                                                            CGRectGetMaxY(self.backgroundProfileView.frame) + padding,
                                                            CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                            mainBackgroundViewHeight);
        } break;
        case CPAEditProfileViewControllerStateSkills: {
            self.mainFieldBackgroundView.frame = CGRectMake(padding,
                                                            CGRectGetMaxY(self.skillsListView.frame) + padding,
                                                            CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                            mainBackgroundViewHeight);
        } break;
    }

    self.industryField.frame = CGRectMake(padding + fieldBorder,
                                          CGRectGetMinY(self.mainFieldBackgroundView.frame) + fieldBorder,
                                          textFieldWidth,
                                          textFieldHeight);
    
    self.tapSkillsLabel.frame = self.industryField.frame;
    
    CGFloat companyFieldY = 0.f;
    CGFloat titleFieldY = 0.f;
    CGFloat cityFieldY = 0.f;
    CGFloat collectionViewY = 0.f;
    CGFloat buttonScrollViewY = 0.f;
    switch (self.state) {
        case CPAEditProfileViewControllerStateText: {
            companyFieldY = CGRectGetMaxY(self.industryField.frame) + fieldBorder;
            titleFieldY = companyFieldY + textFieldHeight + fieldBorder;
            cityFieldY = titleFieldY + textFieldHeight + fieldBorder;
            collectionViewY = CGRectGetMaxY(self.view.bounds);
            buttonScrollViewY = CGRectGetMinY(self.tapSkillsLabel.frame);
        } break;
        case CPAEditProfileViewControllerStateSkills: {
            companyFieldY = CGRectGetMinY(self.industryField.frame);
            titleFieldY = CGRectGetMinY(self.industryField.frame);
            cityFieldY = CGRectGetMinY(self.industryField.frame);
            collectionViewY = CGRectGetMaxY(self.mainFieldBackgroundView.frame) + fieldBorder + padding;
            buttonScrollViewY = CGRectGetMaxY(self.tapSkillsLabel.frame) + fieldBorder;
        } break;
    }

    self.companyField.frame = CGRectMake(padding + fieldBorder,
                                         companyFieldY,
                                         textFieldWidth,
                                         textFieldHeight);
    
    self.titleField.frame = CGRectMake(padding + fieldBorder,
                                       titleFieldY,
                                       textFieldWidth,
                                       textFieldHeight);
    
    self.cityField.frame = CGRectMake(padding + fieldBorder,
                                      cityFieldY,
                                      textFieldWidth / 2,
                                      textFieldHeight);
    
    self.stateField.frame = CGRectMake(CGRectGetMaxX(self.cityField.frame) + fieldBorder,
                                       CGRectGetMinY(self.cityField.frame),
                                       (textFieldWidth / 2) - fieldBorder,
                                       textFieldHeight);
    
    self.buttonScrollView.frame = CGRectMake(padding + fieldBorder,
                                             buttonScrollViewY,
                                             textFieldWidth,
                                             textFieldHeight);
    
    CGFloat collectionViewHeight = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.stateField.frame) - padding;
    self.skillsCollectionView.frame = CGRectMake(padding,
                                                 collectionViewY,
                                                 CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                 collectionViewHeight);
    // At layout, calc the size of each cell. Fit as many as possible on each row
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.skillsCollectionView.collectionViewLayout;
    flowLayout.minimumInteritemSpacing = 4;
    flowLayout.minimumLineSpacing = 4;
    flowLayout.sectionInset = UIEdgeInsetsMake(5, 0, 5, 0);
    CGFloat width = CGRectGetWidth(self.skillsCollectionView.frame);
    CGFloat cellWidth = (width - flowLayout.minimumInteritemSpacing * 3) / 4;
    flowLayout.itemSize = CGSizeMake(cellWidth, 30);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overrides

- (void)setState:(CPAEditProfileViewControllerState)state animated:(BOOL)animated {
    _state = state;
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutViews];
            [self updateViewContent];
        }];
    } else {
        [self layoutViews];
        [self updateViewContent];
    }
}

- (void)setState:(CPAEditProfileViewControllerState)state {
    [self setState:state animated:NO];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1; // always have a single section
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.skillsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CPASkillsCollectionViewCell *cell = (CPASkillsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"skillCell" forIndexPath:indexPath];
    cell.skillString = self.skillsArray[indexPath.item];
    if ([self.userSkillsMutableArray containsObject:self.skillsArray[indexPath.item]]) { // need to check if this is a selected cell since we reuse cells
        cell.state = CPASkillsCollectionViewCellStateSelected;
    } else {
        cell.state = CPASkillsCollectionViewCellStateNotSelected;
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CPASkillsCollectionViewCell *cell = (CPASkillsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell performAnimation];
    [self shouldToggleSkillForCell:cell];
}

- (void)shouldToggleSkillForCell:(CPASkillsCollectionViewCell *)cell {
    if (cell.state == CPASkillsCollectionViewCellStateNotSelected) {

        cell.state = CPASkillsCollectionViewCellStateSelected;
        [self.userSkillsMutableArray addObject:cell.skillString];
        
        // Update the list of skills and the reset the layout
        [self updateUserSkillListLabel];
        [self layoutViews];
    } else {
        cell.state = CPASkillsCollectionViewCellStateNotSelected;
        [self.userSkillsMutableArray removeObject:cell.skillString];
        
        // Update the list of skills and the reset the layout
        [self updateUserSkillListLabel];
        [self layoutViews];
    }
}

- (void)updateUserSkillListLabel {
    
    NSMutableString *newSkillLabelString = [[NSMutableString alloc] initWithString:@""];;
    
    for (int i = 0; i < self.userSkillsMutableArray.count; i++) {
        
        // We only want to add a " • " to the string if there is more than 1 invite
        if (i == 0) {
            NSString *skillStringToAdd = [self.userSkillsMutableArray objectAtIndex:i];
            [newSkillLabelString appendString:[NSString stringWithFormat:@"%@", skillStringToAdd]];
        } else {
            NSString *skillStringToAdd = [self.userSkillsMutableArray objectAtIndex:i];
            [newSkillLabelString appendString:[NSString stringWithFormat:@" • %@", skillStringToAdd]];
        }
    }
    
    self.skillsListLabel.text = newSkillLabelString;
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    self.industryPickerView.hidden = YES; // also hide any pickers that are up
    self.statePickerView.hidden = YES;
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

    if (textField == self.industryField) {
        [self.view endEditing:YES]; // get rid of any keyboard
        self.industryPickerView.hidden = NO;
        return NO;
    } else if (textField == self.stateField) {
        [self.view endEditing:YES]; // get rid of any keyboard
        self.industryPickerView.hidden = YES;
        self.statePickerView.hidden = NO;
        return NO;
    } else {
        self.industryPickerView.hidden = YES;
        return YES;
    }
}

#pragma mark - UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // Handle the pick

    NSString *rowString = [[self pickerView:pickerView attributedTitleForRow:row forComponent:component] string];
    
    if (pickerView == self.industryPickerView) {
        self.industryField.text = rowString;
        [self updateViewsWithSkill:rowString];
    } else if (pickerView == self.statePickerView) {
        self.stateField.text = rowString;
    }
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    
    NSInteger rows;
    if (pickerView == self.industryPickerView) {
        rows = self.skills.skillTitles.count;
    } else if (pickerView == self.statePickerView) {
        rows = 51;
    }
    return rows;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    NSAttributedString *rowString;
    
    if (pickerView == self.industryPickerView) {
        NSString *industryString = self.skills.skillTitles[row];
        
        rowString = [[NSAttributedString alloc] initWithString:industryString attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f]}];
    } else if (pickerView == self.statePickerView) {
        rowString = [[NSAttributedString alloc] initWithString:@"State" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                        NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f]}];
    }
    
    return rowString;
    
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}

#pragma mark - CPAButtonScrollViewDelegate

- (void)buttonScrollViewButtonStringSelected:(NSString *)buttonString {
    NSLog(@"%@ pressed", buttonString);
    [self updateViewsWithSkill:buttonString];
}

- (void)updateViewsWithSkill:(NSString *)skillString {
    
    if ([skillString isEqualToString:@"Accounting"]) {
        self.skillsArray = self.skills.accounting;
    } else if ([skillString isEqualToString:@"Finance"]) {
        self.skillsArray = self.skills.finance;
    }
    [self.skillsCollectionView reloadData];
}

#pragma mark - Buttons / Gestures

- (void)nextBarButtonPressed:(UIBarButtonItem *)barButton {
    
    // Hide any controls on screen
    self.industryPickerView.hidden = YES;
    self.statePickerView.hidden = YES;
    
    if ([self.firstNameField.text isEqualToString:@""]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:@"Please enter your first name in the provided text field to continue."
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [errorAlert addAction:defaultAction];
        [self presentViewController:errorAlert animated:YES completion:nil];
        return;
    } else if ([self.industryField.text isEqualToString:@""]) {
        UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:@"Please enter the industry of your profession in the provided text field to continue"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [errorAlert addAction:defaultAction];
        [self presentViewController:errorAlert animated:YES completion:nil];
        return;
    }
    
    if (self.state == CPAEditProfileViewControllerStateText) {
        [self setState:CPAEditProfileViewControllerStateSkills animated:YES];
    } else if (self.state == CPAEditProfileViewControllerStateSkills) {
        [self updateParseWithProfileInformation];
        CPAAddFriendsViewController *friendsVC = [[CPAAddFriendsViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:friendsVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }
    
}

- (void)updateParseWithProfileInformation {
    
    if ([self.firstNameField.text length] > 0 && self.firstNameField.text != nil && ![self.firstNameField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.firstNameField.text forKey:@"firstName"];
    }
    if ([self.lastNameField.text length] > 0 && self.lastNameField.text != nil && ![self.lastNameField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.lastNameField.text forKey:@"lastName"];
    }
    if ([self.industryField.text length] > 0 && self.industryField.text != nil && ![self.industryField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.industryField.text forKey:@"industry"];
    }
    if ([self.companyField.text length] > 0 && self.companyField.text != nil && ![self.companyField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.companyField.text forKey:@"company"];
    }
    if ([self.titleField.text length] > 0 && self.titleField.text != nil && ![self.titleField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.titleField.text forKey:@"jobTitle"];
    }
    if ([self.cityField.text length] > 0 && self.cityField.text != nil && ![self.cityField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.cityField.text forKey:@"city"];
    }
    if ([self.stateField.text length] > 0 && self.stateField.text != nil && ![self.stateField.text isEqualToString:@""]) {
        [[PFUser currentUser] setObject:self.stateField.text forKey:@"state"];
    }
    if (self.userSkillsMutableArray.count > 0) {
        NSArray *userSkillsArray = [[NSArray alloc] initWithArray:self.userSkillsMutableArray];
        [[PFUser currentUser] setObject:userSkillsArray forKey:@"skills"];
    }
    [[PFUser currentUser] saveEventually];
}

- (void)backBarButtonPressed:(UIBarButtonItem *)barButton {
    if (self.state == CPAEditProfileViewControllerStateText) { // this button should not be visible during this state, so perform no action
        return;
    } else if (self.state == CPAEditProfileViewControllerStateSkills) {
        [self setState:CPAEditProfileViewControllerStateText animated:YES];
    }
}

- (void)mainViewTapFired:(UIGestureRecognizer *)sender {
    [self.view endEditing:YES];
    self.industryPickerView.hidden = YES;
    self.statePickerView.hidden = YES;
}

#pragma mark - UIView sizing

-(CGFloat)maxHeightForSkillsViewToFitSubviews:(UIView *)featureView {
    float height = 0;
    
    for (UIView *v in [featureView subviews]) {
        float fh = v.frame.origin.y + v.frame.size.height;
        height = MAX(fh, height);
    }
    return height;
}

@end
