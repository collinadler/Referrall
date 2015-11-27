//
//  CPAAddJobViewController.m
//  Referrall
//
//  Created by Collin Adler on 11/6/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <ParseUI/ParseUI.h>
#import <Parse/Parse.h>
#import "CPAAddJobViewController.h"
#import "CPAConstants.h"
#import "CPASkills.h"
#import "CPAButtonScrollView.h"
#import "CPASkillsCollectionViewCell.h"

#define PAGE_CONTROL_SIZE 7.5
#define LOCATION_LABEL_HEIGHT 40

typedef NS_ENUM(NSInteger, CPAAddJobControllerState) {
    CPAAddJobControllerStateJobTitle,
    CPAAddJobControllerStateCompany,
    CPAAddJobControllerStateLocation,
    CPAAddJobControllerStateIndustry,
    CPAAddJobControllerStateDescription,
    CPAAddJobControllerStateSkills
};

@interface CPAAddJobViewController () <MKMapViewDelegate, UITextFieldDelegate, UIPickerViewDelegate, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, CPAButtonScrollViewDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) CPAAddJobControllerState state;

@property (nonatomic, strong) UIView *mainView;

/* Scroll view subviews */

// User info
@property (nonatomic, strong) PFImageView *userImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userSubtitleLabel;

// Job info
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;

@property (nonatomic, strong) UIView *descriptionDivider;
@property (nonatomic, strong) UILabel *descriptionTitleLabel;
@property (nonatomic, strong) UILabel *descriptionLabel;

// Inputs
@property (nonatomic, strong) UIView *firstPageView;
@property (nonatomic, strong) UIView *secondPageView;
@property (nonatomic, strong) UIView *thirdPageView;
@property (nonatomic, strong) UIView *fourthPageView;
@property (nonatomic, strong) UIView *fifthPageView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;

@property (nonatomic, strong) UITextField *jobTitleTextField;
@property (nonatomic, strong) UITextField *companyTextField;
@property (nonatomic, strong) UITextField *industryTextField;

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *mapPinImageView;
@property (nonatomic, strong) UILabel *mapLocationLabel;
@property (nonatomic, strong) UIButton *centerLocationButton;

@property (nonatomic, strong) UILabel *industryLabel;
@property (nonatomic, strong) CPAButtonScrollView *industryButtonScrollView;
@property (nonatomic, strong) UILabel *typeLabel;
@property (nonatomic, strong) CPAButtonScrollView *typeButtonScrollView;
@property (nonatomic, strong) UILabel *experienceLabel;
@property (nonatomic, strong) CPAButtonScrollView *experienceButtonScrollView;

@property (nonatomic, strong) UITextField *descriptionTextField;

// Text field strings
@property (nonatomic, strong) NSString *jobTitleString;
@property (nonatomic, strong) NSString *companyString;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) NSString *industryString;
@property (nonatomic, strong) NSString *experienceString;
@property (nonatomic, strong) NSString *typeString;
@property (nonatomic, strong) NSString *descriptionString;

// Skills views
@property (nonatomic, strong) UIView *backgroundSkillsView;
@property (nonatomic, strong) UICollectionView *skillsCollectionView;

// Skills subviews of mainView
@property (nonatomic, strong) UILabel *skillsLabel;
@property (nonatomic, strong) UILabel *skillsListLabel;

// Subviews of background skills view
@property (nonatomic, strong) UILabel *tapSkillsLabel;
@property (nonatomic, strong) CPAButtonScrollView *buttonScrollView;

// Data properties
@property (nonatomic, strong) CPASkills *skills;
@property (nonatomic, strong) NSArray *skillsArray; // this is what our colleciton view will pull from
@property (nonatomic, strong) NSMutableArray *jobSkillsMutableArray; // the user's current skills

// Location properties
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

// Networking
@property (nonatomic, assign) UIBackgroundTaskIdentifier jobPostBackgroundTaskId;

// Keep track of keyboard height
@property (nonatomic, assign) CGFloat currentKeyboardHeight;

@end

@implementation CPAAddJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.skillsArray = [[NSArray alloc] init];
    self.jobSkillsMutableArray = [[NSMutableArray alloc] init];
    if (self.skillsArray) {
        self.skills = [[CPASkills alloc] init];
    }
    
    self.title = @"Add A Job";
    self.view.layer.masksToBounds = YES;
    self.view.backgroundColor = [CPAConstants lightGrayColor];
    UIBarButtonItem *finishBarButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Finish", @"Go to next button")
                                                                      style:UIBarButtonItemStyleDone
                                                                     target:self
                                                                     action:@selector(finishBarButtonPressed:)];
    finishBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = finishBarButton;
    _currentKeyboardHeight = 0.0f;
    
    // Main scroll view
    self.mainView = [[UIView alloc] init];
    self.mainView.backgroundColor = [UIColor whiteColor];
    self.mainView.layer.shadowOpacity = 0.15;
    self.mainView.layer.shadowOffset = CGSizeMake(1.0, 1.2);
    self.mainView.layer.shadowRadius = 1.0;
    self.mainView.layer.masksToBounds = YES;
    
    self.jobTitleString = @"[Job Title]";
    self.companyString = @"[Company]";
    self.locationString = @"[Location]";
    self.industryString = @"[Industry]";
    self.descriptionString = @"[Add a description...]";
    self.experienceString = @"Entry"; // Default to most common value
    self.typeString = @"Full-time"; // Default to most common value
    
    // Job inputs
    self.firstPageView = [[UIView alloc] init];
    self.firstPageView.backgroundColor = [UIColor whiteColor];
    self.firstPageView.layer.cornerRadius = PAGE_CONTROL_SIZE / 2;
    self.firstPageView.layer.masksToBounds = YES;
    
    self.secondPageView = [[UIView alloc] init];
    self.secondPageView.backgroundColor = [UIColor whiteColor];
    self.secondPageView.layer.cornerRadius = PAGE_CONTROL_SIZE / 2;
    self.secondPageView.layer.masksToBounds = YES;
    
    self.thirdPageView = [[UIView alloc] init];
    self.thirdPageView.backgroundColor = [UIColor whiteColor];
    self.thirdPageView.layer.cornerRadius = PAGE_CONTROL_SIZE / 2;
    self.thirdPageView.layer.masksToBounds = YES;

    self.fourthPageView = [[UIView alloc] init];
    self.fourthPageView.backgroundColor = [UIColor whiteColor];
    self.fourthPageView.layer.cornerRadius = PAGE_CONTROL_SIZE / 2;
    self.fourthPageView.layer.masksToBounds = YES;

    self.fifthPageView = [[UIView alloc] init];
    self.fifthPageView.backgroundColor = [UIColor whiteColor];
    self.fifthPageView.layer.cornerRadius = PAGE_CONTROL_SIZE / 2;
    self.fifthPageView.layer.masksToBounds = YES;
    
    self.state = CPAAddJobControllerStateJobTitle;
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backButton.backgroundColor = [CPAConstants skyBlueColor];
    self.backButton.layer.cornerRadius = 4;
    self.backButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.backButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"BACK" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.5f],
                                                                                                           NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                           NSKernAttributeName : @2.0}] forState:UIControlStateNormal];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.forwardButton.backgroundColor = [CPAConstants skyBlueColor];
    self.forwardButton.layer.cornerRadius = 4;
    self.forwardButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.forwardButton addTarget:self action:@selector(forwardButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.forwardButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"NEXT" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:9.5f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor whiteColor],
                                                                                                                 NSKernAttributeName : @2.0}] forState:UIControlStateNormal];
    
    self.jobTitleTextField = [[UITextField alloc] init];
    self.jobTitleTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Job Title" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
                                                                                                                                                                                 NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.jobTitleTextField.backgroundColor = [UIColor whiteColor];
    self.jobTitleTextField.textAlignment = NSTextAlignmentCenter;
    self.jobTitleTextField.adjustsFontSizeToFitWidth = YES;
    [self.jobTitleTextField.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [self.jobTitleTextField.layer setMasksToBounds:NO];
    self.jobTitleTextField.delegate = self;

    self.companyTextField = [[UITextField alloc] init];
    self.companyTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Company" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
                                                                                                                                                             NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.companyTextField.backgroundColor = [UIColor whiteColor];
    self.companyTextField.textAlignment = NSTextAlignmentCenter;
    self.companyTextField.adjustsFontSizeToFitWidth = YES;
    [self.companyTextField.layer setBackgroundColor:[UIColor whiteColor].CGColor];
    [self.companyTextField.layer setMasksToBounds:NO];
    self.companyTextField.delegate = self;
    
    // Map View
    CLLocationCoordinate2D userCoordinate = CLLocationCoordinate2DMake(39.8282, -98.5795);
    MKCoordinateSpan mapSpan = MKCoordinateSpanMake(48.0, 62.0);
    self.mapView = [[MKMapView alloc] init];
    [self.mapView setRegion:MKCoordinateRegionMake(userCoordinate, mapSpan)];
    self.mapView.showsUserLocation = YES;
    self.mapView.showsPointsOfInterest = NO;
    self.mapView.delegate = self;
    
    self.mapPinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map_pin"]];
    [self.mapView addSubview:self.mapPinImageView];
    
    self.mapLocationLabel = [[UILabel alloc] init];
    self.mapLocationLabel.backgroundColor = [CPAConstants skyBlueColor];
    self.mapLocationLabel.numberOfLines = 2;
    self.mapLocationLabel.adjustsFontSizeToFitWidth = YES;
    self.mapLocationLabel.textAlignment = NSTextAlignmentCenter;
    self.mapLocationLabel.layer.cornerRadius = LOCATION_LABEL_HEIGHT / 2;
    self.mapLocationLabel.layer.masksToBounds = YES;
    NSMutableAttributedString *locationLabelString = [[NSMutableAttributedString alloc] initWithString:@"Move Map To Set Location" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f],
                                                                                                                                                  NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [self.mapLocationLabel setAttributedText:locationLabelString];
    [self.mapView addSubview:self.mapLocationLabel];
    
    self.centerLocationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.centerLocationButton setBackgroundImage:[UIImage imageNamed:@"map_center"] forState:UIControlStateNormal];
    self.centerLocationButton.backgroundColor = [CPAConstants skyBlueColor];
    self.centerLocationButton.layer.cornerRadius = 3;
    self.centerLocationButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.centerLocationButton.layer.borderWidth = 1;
    [self.centerLocationButton addTarget:self
                                  action:@selector(centerLocationButtonPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:self.centerLocationButton];
    
    // Industry picker
    self.industryLabel = [[UILabel alloc] init];
    [self.industryLabel setBackgroundColor:[UIColor clearColor]];
    self.industryLabel.numberOfLines = 1;
    self.industryLabel.textAlignment = NSTextAlignmentCenter;
    [self.industryLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Select Industry" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor blackColor]}]];

    self.industryButtonScrollView = [[CPAButtonScrollView alloc] init];
    self.industryButtonScrollView.buttonDelegate = self;

    self.typeLabel = [[UILabel alloc] init];
    [self.typeLabel setBackgroundColor:[UIColor clearColor]];
    self.typeLabel.numberOfLines = 1;
    self.typeLabel.textAlignment = NSTextAlignmentCenter;
    [self.typeLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Select Job Type" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                            NSForegroundColorAttributeName : [UIColor blackColor]}]];
    
    self.typeButtonScrollView = [[CPAButtonScrollView alloc] init];
    self.typeButtonScrollView.buttonDelegate = self;

    self.experienceLabel = [[UILabel alloc] init];
    [self.experienceLabel setBackgroundColor:[UIColor clearColor]];
    self.experienceLabel.numberOfLines = 1;
    self.experienceLabel.textAlignment = NSTextAlignmentCenter;
    [self.experienceLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Select Experience" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor blackColor]}]];
    
    self.experienceButtonScrollView = [[CPAButtonScrollView alloc] init];
    self.experienceButtonScrollView.buttonDelegate = self;
    
    // Description text field
    self.descriptionTextField = [[UITextField alloc] init];
    self.descriptionTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@" Add a Description (e.g. XX Company is..." attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                        NSForegroundColorAttributeName : [UIColor grayColor]}];
    self.descriptionTextField.backgroundColor = [UIColor whiteColor];
    [self.descriptionTextField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    self.descriptionTextField.delegate = self;
    
    // Views for adding skills
    self.backgroundSkillsView = [[UIView alloc] init];
    self.backgroundSkillsView.backgroundColor = [UIColor whiteColor];
    self.backgroundSkillsView.layer.shadowOpacity = 0.15;
    self.backgroundSkillsView.layer.shadowOffset = CGSizeMake(1.0, 1.2);
    self.backgroundSkillsView.layer.shadowRadius = 1.0;
    self.backgroundSkillsView.layer.masksToBounds = YES;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100, 100);
    
    self.skillsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.skillsCollectionView.backgroundColor = [UIColor clearColor];
    self.skillsCollectionView.dataSource = self;
    self.skillsCollectionView.delegate = self;
    
    // Skills subviews of main view
    self.skillsLabel = [[UILabel alloc] init];
    self.skillsLabel.backgroundColor = [UIColor clearColor];
    self.skillsLabel.adjustsFontSizeToFitWidth = YES;
    self.skillsLabel.textAlignment = NSTextAlignmentCenter;
    self.skillsLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Skills"
                                                                      attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                   NSForegroundColorAttributeName : [UIColor grayColor]}];
    
    self.skillsListLabel = [[UILabel alloc] init];
    self.skillsListLabel.backgroundColor = [UIColor clearColor];
    self.skillsListLabel.textColor = [CPAConstants skyBlueColor];
    self.skillsListLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
    self.skillsListLabel.textAlignment = NSTextAlignmentCenter;
    self.skillsListLabel.adjustsFontSizeToFitWidth = YES;
    self.skillsListLabel.numberOfLines = 0; // make this span multiple lines if necessary

    // Subviews of background skills list view
    self.tapSkillsLabel = [[UILabel alloc] init];
    self.tapSkillsLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Tap Skills Below To Add To Job" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:13.0f],
                                                                                                                                            NSForegroundColorAttributeName : [UIColor blackColor]}];
    self.tapSkillsLabel.adjustsFontSizeToFitWidth = YES;
    self.tapSkillsLabel.textAlignment = NSTextAlignmentCenter;
    self.tapSkillsLabel.backgroundColor = [UIColor clearColor];
    [self.backgroundSkillsView addSubview:self.tapSkillsLabel];
    
    self.buttonScrollView = [[CPAButtonScrollView alloc] init];
    self.buttonScrollView.buttonDelegate = self;
    [self.backgroundSkillsView addSubview:self.buttonScrollView];
    
    // Register cell classes
    [self.skillsCollectionView registerClass:[CPASkillsCollectionViewCell class] forCellWithReuseIdentifier:@"skillCell"];
    
    for (UIView *view in @[self.firstPageView, self.secondPageView, self.thirdPageView, self.fourthPageView, self.fifthPageView, self.mainView, self.backButton, self.forwardButton, self.jobTitleTextField, self.companyTextField, self.mapView, self.industryButtonScrollView, self.industryLabel, self.typeLabel, self.typeButtonScrollView, self.experienceLabel, self.experienceButtonScrollView, self.descriptionTextField, self.backgroundSkillsView, self.skillsCollectionView]) {
        [self.view addSubview:view];
    }
    
    /* Scroll view subviews */
    self.userImageView  = [[PFImageView alloc] init];
    [self.userImageView setBackgroundColor:[UIColor clearColor]];
    [self.userImageView setOpaque:YES];
    self.userImageView.image = [UIImage imageNamed:@"profile"];
    if ([[PFUser currentUser] objectForKey:@"profilePictureSmall"]) {
        self.userImageView.file = [[PFUser currentUser] objectForKey:@"profilePictureSmall"];
        [self.userImageView loadInBackground];
    }
    
    self.nameLabel = [[UILabel alloc] init];
    [self.nameLabel setBackgroundColor:[UIColor clearColor]];
    [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.5f]];
    [self.nameLabel setTextColor:[UIColor blackColor]];
    [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    NSString *firstName = [[PFUser currentUser] objectForKey:@"firstName"];
    NSString *lastName = [[PFUser currentUser] objectForKey:@"lastName"];
    NSString *fullNameString = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    [self.nameLabel setText:fullNameString];

    self.userSubtitleLabel = [[UILabel alloc] init];
    [self.userSubtitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.userSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.5f]];
    [self.userSubtitleLabel setTextColor:[UIColor grayColor]];
    [self.userSubtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.userSubtitleLabel setNumberOfLines:2];
    // Set user name
    NSString *jobString = [[NSString alloc] init];
    if ([[PFUser currentUser] objectForKey:@"jobTitle"] && [[PFUser currentUser] objectForKey:@"company"]) {
        jobString = [NSString stringWithFormat:@"%@ at %@", [[PFUser currentUser] objectForKey:@"jobTitle"], [[PFUser currentUser] objectForKey:@"company"]];
    } else if ([[PFUser currentUser] objectForKey:@"industry"]) {
        jobString = [NSString stringWithFormat:@"%@", [[PFUser currentUser] objectForKey:@"industry"]];
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
    
    self.subtitleLabel = [[UILabel alloc] init];
    [self.subtitleLabel setBackgroundColor:[UIColor clearColor]];
    self.subtitleLabel.adjustsFontSizeToFitWidth = YES;
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;

    [self updateLabelsWithCurrentStrings];
    
    self.descriptionDivider = [[UIView alloc] init];
    self.descriptionDivider.backgroundColor = [UIColor lightGrayColor];
    
    self.descriptionTitleLabel = [[UILabel alloc] init];
    [self.descriptionTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.descriptionTitleLabel setAttributedText:[[NSAttributedString alloc] initWithString:@"Description" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                         NSForegroundColorAttributeName : [UIColor grayColor]}]];
    
    self.descriptionLabel = [[UILabel alloc] init];
    [self.descriptionLabel setBackgroundColor:[UIColor clearColor]];
    self.descriptionLabel.numberOfLines = 0;
    [self.descriptionLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [self.descriptionLabel setAttributedText:[[NSAttributedString alloc] initWithString:self.descriptionString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                            NSForegroundColorAttributeName : [UIColor blackColor]}]];
    
    for (UIView *view in @[self.userImageView, self.nameLabel, self.userSubtitleLabel, self.titleView, self.titleLabel, self.subtitleLabel, self.descriptionDivider, self.descriptionTitleLabel, self.descriptionLabel, self.skillsLabel, self.skillsListLabel]) {
        [self.mainView addSubview:view];
    }
    
    [self.jobTitleTextField becomeFirstResponder];
    
    // Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [self startStandardUpdates];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Set the titles for our button scroll views and add default items
    self.experienceButtonScrollView.buttonTitles = @[@"Executive", @"Director", @"Mid-Senior", @"Associate", @"Entry", @"Internship", @"N/A"];
//    [self.experienceButtonScrollView centerScrollViewOnButtonWithStringTitle:@"Associate"];
    
    self.typeButtonScrollView.buttonTitles = @[@"Full-time", @"Part-time", @"Contract", @"Temp", @"Other"];
    [self.typeButtonScrollView centerScrollViewOnButtonWithStringTitle:@"Full-time"];

    self.industryButtonScrollView.buttonTitles = self.skills.skillTitles;
    self.buttonScrollView.buttonTitles = self.skills.skillTitles;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat padding = 10;
    
    self.mainView.frame = CGRectMake(padding,
                                           padding,
                                           CGRectGetWidth(self.view.bounds) - padding * 2,
                                           CGRectGetHeight(self.view.bounds) - padding * 2);
    
    [self layoutViews];
}

- (void)layoutViews {

    CGFloat padding = 10;
    CGFloat smallPadding = 5;
    CGFloat textFieldHeight = 30;
    CGFloat smallTextFieldHeight = 15;
    CGFloat userImageViewSize = 40.f;
    CGFloat textFieldWidth = CGRectGetWidth(self.view.bounds);
    CGFloat leftSideTextFieldX = CGRectGetMinX(self.view.frame) - textFieldWidth - padding;
    CGFloat visibleTextFieldX = CGRectGetMinX(self.view.frame);
    CGFloat rightSideTextFieldX = CGRectGetMaxX(self.view.frame);
    CGFloat pageControlWidth = PAGE_CONTROL_SIZE * 11; // make space for 5 page controls, plus the 6 spaces between them
    CGFloat buttonWidth = (CGRectGetWidth(self.view.bounds) - pageControlWidth - padding * 2) / 2;
    CGFloat buttonHeight = 20;
    CGFloat mapPinSize = 40;
    CGFloat centerLocationButtonSize = 33;
    CGFloat backgroundSkillsViewHeight = 60;
    CGFloat scrollableButtonViewHeight = 30;
    
    // Size the label heights needed first
    CGSize maxTitleLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (smallPadding * 2), CGFLOAT_MAX);
    CGSize titleLabelSize = [self.titleLabel sizeThatFits:maxTitleLabelSize];
    CGSize maxSubtitleLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (smallPadding * 2), CGFLOAT_MAX);
    CGSize subtitleLabelSize = [self.subtitleLabel sizeThatFits:maxSubtitleLabelSize];
    CGFloat totalTitleAndSubtitleHeight = titleLabelSize.height + subtitleLabelSize.height;

    CGSize maxSkillsListLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds) - padding * 2, CGFLOAT_MAX);
    CGSize skillsListLabelSize = [self.skillsListLabel sizeThatFits:maxSkillsListLabelSize];
    
    CGSize maxDescriptionLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - (smallPadding * 2), CGFLOAT_MAX);
    CGSize descriptionLabelSize = [self.descriptionLabel sizeThatFits:maxDescriptionLabelSize];
    
    CGFloat jobTitleTextFieldX = 0.f;
    CGFloat companyTextFieldX = 0.f;
    CGFloat locationTextFieldX = 0.f;
    CGFloat industryTextFieldX = 0.f;
    CGFloat descriptionTextFieldX = 0.f;
    CGFloat backButtonX = 0.f;
    CGFloat forwardButtonX = 0.f;
    CGFloat mainViewY = 0.f;
    CGFloat userImageViewY = 0.f;
    CGFloat descriptionDividerY = 0.f;
    CGFloat backgroundSkillsViewX = 0.f;
    CGFloat skillsLabelHeight = 0.f;
    CGFloat skillsListLabelHeight = 0.f;
    CGFloat collectionViewX = 0.f;
    
    switch (self.state) {
        case CPAAddJobControllerStateJobTitle: {

            jobTitleTextFieldX = visibleTextFieldX;
            companyTextFieldX = rightSideTextFieldX;
            locationTextFieldX = rightSideTextFieldX;
            industryTextFieldX = rightSideTextFieldX;
            descriptionTextFieldX = rightSideTextFieldX;
            backButtonX = CGRectGetMinX(self.view.frame) - buttonWidth;
            forwardButtonX = CGRectGetMaxX(self.fifthPageView.frame) + PAGE_CONTROL_SIZE;
            mainViewY = padding;
            userImageViewY = CGRectGetMinY(self.mainView.bounds) + smallPadding;
            descriptionDividerY = CGRectGetMaxY(self.titleView.frame) + smallPadding;
            backgroundSkillsViewX = CGRectGetMaxX(self.view.bounds);
            skillsLabelHeight = 0.f;
            skillsListLabelHeight = 0.f;
            collectionViewX = CGRectGetMaxX(self.view.bounds);
            
        } break;
        case CPAAddJobControllerStateCompany: {

            jobTitleTextFieldX = leftSideTextFieldX;
            companyTextFieldX = visibleTextFieldX;
            locationTextFieldX = rightSideTextFieldX;
            industryTextFieldX = rightSideTextFieldX;
            descriptionTextFieldX = rightSideTextFieldX;
            backButtonX = padding;
            forwardButtonX = CGRectGetMaxX(self.fifthPageView.frame) + PAGE_CONTROL_SIZE;
            mainViewY = padding;
            userImageViewY = CGRectGetMinY(self.mainView.bounds) + smallPadding;
            descriptionDividerY = CGRectGetMaxY(self.titleView.frame) + smallPadding;
            backgroundSkillsViewX = CGRectGetMaxX(self.view.bounds);
            skillsLabelHeight = 0.f;
            skillsListLabelHeight = 0.f;
            collectionViewX = CGRectGetMaxX(self.view.bounds);

        } break;
        case CPAAddJobControllerStateLocation: {
            
            jobTitleTextFieldX = leftSideTextFieldX;
            companyTextFieldX = leftSideTextFieldX;
            locationTextFieldX = visibleTextFieldX;
            industryTextFieldX = rightSideTextFieldX;
            descriptionTextFieldX = rightSideTextFieldX;
            backButtonX = padding;
            forwardButtonX = CGRectGetMaxX(self.fifthPageView.frame) + PAGE_CONTROL_SIZE;
            mainViewY = padding;
            userImageViewY = CGRectGetMinY(self.mainView.bounds) + smallPadding;
            descriptionDividerY = CGRectGetMaxY(self.titleView.frame) + smallPadding;
            backgroundSkillsViewX = CGRectGetMaxX(self.view.bounds);
            skillsLabelHeight = 0.f;
            skillsListLabelHeight = 0.f;
            collectionViewX = CGRectGetMaxX(self.view.bounds);

        } break;
        case CPAAddJobControllerStateIndustry: {
            
            jobTitleTextFieldX = leftSideTextFieldX;
            companyTextFieldX = leftSideTextFieldX;
            locationTextFieldX = leftSideTextFieldX;
            industryTextFieldX = CGRectGetMinX(self.view.bounds);
            descriptionTextFieldX = rightSideTextFieldX;
            backButtonX = padding;
            forwardButtonX = CGRectGetMaxX(self.fifthPageView.frame) + PAGE_CONTROL_SIZE;
            mainViewY = padding;
            userImageViewY = CGRectGetMinY(self.mainView.bounds) + smallPadding;
            descriptionDividerY = CGRectGetMaxY(self.titleView.frame) + smallPadding;
            backgroundSkillsViewX = CGRectGetMaxX(self.view.bounds);
            skillsLabelHeight = 0.f;
            skillsListLabelHeight = 0.f;
            collectionViewX = CGRectGetMaxX(self.view.bounds);

        } break;
        case CPAAddJobControllerStateDescription: {
            
            jobTitleTextFieldX = leftSideTextFieldX;
            companyTextFieldX = leftSideTextFieldX;
            locationTextFieldX = leftSideTextFieldX;
            industryTextFieldX = leftSideTextFieldX - padding * 3;
            descriptionTextFieldX = visibleTextFieldX;
            backButtonX = padding;
            forwardButtonX = CGRectGetMaxX(self.view.frame);
            userImageViewY = CGRectGetMinY(self.mainView.bounds) + smallPadding;
            descriptionDividerY = CGRectGetMaxY(self.titleView.frame) + smallPadding;
            backgroundSkillsViewX = CGRectGetMaxX(self.view.bounds);
            skillsLabelHeight = 0.f;
            skillsListLabelHeight = 0.f;
            collectionViewX = CGRectGetMaxX(self.view.bounds);

            // For the mainview, move up based on the number of lines of the description text
            CGSize descriptionLabelSize = CGSizeMake(self.descriptionLabel.frame.size.width, MAXFLOAT);
            CGFloat actualDescriptionLabelHeight = [self.descriptionLabel sizeThatFits:descriptionLabelSize].height;
            mainViewY = padding + (14.5 - actualDescriptionLabelHeight);

        } break;
        case CPAAddJobControllerStateSkills: {
            mainViewY = padding;
            userImageViewY = CGRectGetMinY(self.mainView.bounds) - userImageViewSize;
            descriptionDividerY = CGRectGetMinY(self.userImageView.frame) - descriptionLabelSize.height;
            jobTitleTextFieldX = leftSideTextFieldX;
            companyTextFieldX = leftSideTextFieldX;
            locationTextFieldX = leftSideTextFieldX;
            industryTextFieldX = leftSideTextFieldX;
            descriptionTextFieldX = leftSideTextFieldX;
            backButtonX = CGRectGetMinX(self.view.frame) - buttonWidth;
            forwardButtonX = CGRectGetMaxX(self.view.frame);
            backgroundSkillsViewX = CGRectGetMinX(self.view.bounds) + padding;
            skillsLabelHeight = 20;
            skillsListLabelHeight = skillsListLabelSize.height;
            collectionViewX = CGRectGetMinX(self.view.bounds) + padding;
        }
    }
    
    /* Scroll view subviews */
    self.userImageView.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                          userImageViewY,
                                          userImageViewSize,
                                          userImageViewSize);
    
    CGSize maxNameLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.bounds) - userImageViewSize - (smallPadding * 3), CGFLOAT_MAX);
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:maxNameLabelSize];
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.userImageView.frame) + smallPadding,
                                      CGRectGetMinY(self.userImageView.frame),
                                      nameLabelSize.width,
                                      nameLabelSize.height);
    
    CGSize maxUserJobLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - userImageViewSize - (smallPadding * 3), CGFLOAT_MAX);
    CGSize userJobLabelSize = [self.userSubtitleLabel sizeThatFits:maxUserJobLabelSize];
    self.userSubtitleLabel.frame = CGRectMake(CGRectGetMaxX(self.userImageView.frame) + smallPadding,
                                              CGRectGetMaxY(self.nameLabel.frame),
                                              userJobLabelSize.width,
                                              userJobLabelSize.height);
    
    self.titleView.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                      CGRectGetMaxY(self.userImageView.frame) + smallPadding,
                                      CGRectGetWidth(self.mainView.bounds) - (smallPadding * 2),
                                      totalTitleAndSubtitleHeight + smallPadding);
    
    self.titleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                       CGRectGetMinY(self.titleView.frame) + smallPadding / 2,
                                       CGRectGetWidth(self.mainView.frame) - (smallPadding * 2),
                                       titleLabelSize.height);
    
    self.subtitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                          CGRectGetMaxY(self.titleLabel.frame),
                                          CGRectGetWidth(self.mainView.frame) - (smallPadding * 2),
                                          subtitleLabelSize.height);
    
    self.descriptionDivider.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                               descriptionDividerY,
                                               CGRectGetWidth(self.mainView.frame) - (smallPadding * 2),
                                               0.5);
    
    self.descriptionTitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                                  CGRectGetMaxY(self.descriptionDivider.frame) + smallPadding,
                                                  CGRectGetWidth(self.mainView.frame) - (smallPadding * 2),
                                                  15);
    
    self.descriptionLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + smallPadding,
                                             CGRectGetMaxY(self.descriptionTitleLabel.frame),
                                             CGRectGetWidth(self.mainView.frame) - (smallPadding * 2),
                                             descriptionLabelSize.height);
    
    // Resize the mainview to contain its subviews
    CGFloat newMainViewHeight = [self maxHeightForMainViewToFitSubviews:self.mainView];
    self.mainView.frame = CGRectMake(padding,
                                     mainViewY,
                                     CGRectGetWidth(self.view.bounds) - (padding * 2),
                                     newMainViewHeight + padding);
    
    self.firstPageView.frame = CGRectMake(CGRectGetMidX(self.view.frame) - PAGE_CONTROL_SIZE * 4.5,
                                          CGRectGetMaxY(self.mainView.frame) + padding + buttonHeight / 2 - PAGE_CONTROL_SIZE / 2,
                                          PAGE_CONTROL_SIZE,
                                          PAGE_CONTROL_SIZE);

    self.secondPageView.frame = CGRectMake(CGRectGetMidX(self.view.frame) - PAGE_CONTROL_SIZE * 2.5,
                                           CGRectGetMaxY(self.mainView.frame) + padding + buttonHeight / 2 - PAGE_CONTROL_SIZE / 2,
                                           PAGE_CONTROL_SIZE,
                                           PAGE_CONTROL_SIZE);

    self.thirdPageView.frame = CGRectMake(CGRectGetMidX(self.view.frame) - PAGE_CONTROL_SIZE * 0.5,
                                          CGRectGetMaxY(self.mainView.frame) + padding + buttonHeight / 2 - PAGE_CONTROL_SIZE / 2,
                                          PAGE_CONTROL_SIZE,
                                          PAGE_CONTROL_SIZE);

    self.fourthPageView.frame = CGRectMake(CGRectGetMidX(self.view.frame) + PAGE_CONTROL_SIZE * 1.5,
                                           CGRectGetMaxY(self.mainView.frame) + padding + buttonHeight / 2 - PAGE_CONTROL_SIZE / 2,
                                           PAGE_CONTROL_SIZE,
                                           PAGE_CONTROL_SIZE);
    
    self.fifthPageView.frame = CGRectMake(CGRectGetMidX(self.view.frame) + PAGE_CONTROL_SIZE * 3.5,
                                          CGRectGetMaxY(self.mainView.frame) + padding + buttonHeight / 2 - PAGE_CONTROL_SIZE / 2,
                                          PAGE_CONTROL_SIZE,
                                          PAGE_CONTROL_SIZE);

    self.backButton.frame = CGRectMake(backButtonX,
                                       CGRectGetMaxY(self.mainView.frame) + padding,
                                       buttonWidth,
                                       buttonHeight);
    
    self.forwardButton.frame = CGRectMake(forwardButtonX,
                                          CGRectGetMaxY(self.mainView.frame) + padding,
                                          buttonWidth,
                                          buttonHeight);
    
    // Adjust to the approrpirate uitextfield
    self.jobTitleTextField.frame = CGRectMake(jobTitleTextFieldX,
                                              CGRectGetMaxY(self.forwardButton.frame) + padding,
                                              textFieldWidth,
                                              textFieldHeight);
    
    self.companyTextField.frame = CGRectMake(companyTextFieldX,
                                             CGRectGetMaxY(self.forwardButton.frame) + padding,
                                             textFieldWidth,
                                             textFieldHeight);
    
    self.mapView.frame = CGRectMake(locationTextFieldX,
                                    CGRectGetMaxY(self.forwardButton.frame) + padding,
                                    textFieldWidth,
                                    CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.forwardButton.frame) - padding);
    
    self.mapPinImageView.frame = CGRectMake(CGRectGetMidX(self.mapView.bounds) - mapPinSize / 2,
                                            CGRectGetMidY(self.mapView.bounds) - mapPinSize,
                                            mapPinSize,
                                            mapPinSize);
    
    CGFloat locationLabelWidth = CGRectGetWidth(self.mapView.frame) - padding * 4;
    self.mapLocationLabel.frame = CGRectMake(CGRectGetMidX(self.mapView.bounds) - locationLabelWidth / 2,
                                             CGRectGetMinY(self.mapPinImageView.frame) - LOCATION_LABEL_HEIGHT / 2,
                                             locationLabelWidth,
                                             LOCATION_LABEL_HEIGHT);
    
    self.centerLocationButton.frame = CGRectMake(CGRectGetMaxX(self.mapView.bounds) - centerLocationButtonSize - padding,
                                                 CGRectGetMaxY(self.mapView.bounds) - centerLocationButtonSize - padding,
                                                 centerLocationButtonSize,
                                                 centerLocationButtonSize);
    
    self.typeLabel.frame = CGRectMake(industryTextFieldX,
                                      CGRectGetMaxY(self.forwardButton.frame) + padding,
                                      textFieldWidth,
                                      smallTextFieldHeight);
    
    self.typeButtonScrollView.frame = CGRectMake(industryTextFieldX,
                                                       CGRectGetMaxY(self.typeLabel.frame) + smallPadding,
                                                       textFieldWidth,
                                                       scrollableButtonViewHeight);
    
    self.experienceLabel.frame = CGRectMake(industryTextFieldX,
                                            CGRectGetMaxY(self.typeButtonScrollView.frame) + padding,
                                            textFieldWidth,
                                            smallTextFieldHeight);
    
    self.experienceButtonScrollView.frame = CGRectMake(industryTextFieldX,
                                                 CGRectGetMaxY(self.experienceLabel.frame) + smallPadding,
                                                 textFieldWidth,
                                                 scrollableButtonViewHeight);
    
    self.industryLabel.frame = CGRectMake(industryTextFieldX,
                                          CGRectGetMaxY(self.experienceButtonScrollView.frame) + padding,
                                          textFieldWidth,
                                          smallTextFieldHeight);

    self.industryButtonScrollView.frame = CGRectMake(industryTextFieldX,
                                               CGRectGetMaxY(self.industryLabel.frame) + smallPadding,
                                               textFieldWidth,
                                               scrollableButtonViewHeight);
    
    self.descriptionTextField.frame = CGRectMake(descriptionTextFieldX,
                                                 CGRectGetMaxY(self.forwardButton.frame) + padding,
                                                 textFieldWidth,
                                                 textFieldHeight);
    
    self.skillsLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds),
                                        CGRectGetMaxY(self.titleView.frame) + smallPadding,
                                        CGRectGetWidth(self.mainView.bounds),
                                        skillsLabelHeight);
    
    self.skillsListLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                            CGRectGetMaxY(self.skillsLabel.frame),
                                            CGRectGetWidth(self.mainView.bounds) - padding * 2,
                                            skillsListLabelHeight);
    
    // Resize the mainview again to contain its subviews
    newMainViewHeight = [self maxHeightForMainViewToFitSubviews:self.mainView];
    self.mainView.frame = CGRectMake(padding,
                                     mainViewY,
                                     CGRectGetWidth(self.view.bounds) - (padding * 2),
                                     newMainViewHeight + padding);
    
    self.backgroundSkillsView.frame = CGRectMake(backgroundSkillsViewX,
                                                 CGRectGetMaxY(self.mainView.frame) + padding,
                                                 CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                 backgroundSkillsViewHeight);
    
    self.tapSkillsLabel.frame = CGRectMake(CGRectGetMinX(self.backgroundSkillsView.bounds),
                                           CGRectGetMinY(self.backgroundSkillsView.bounds),
                                           CGRectGetWidth(self.backgroundSkillsView.bounds),
                                           CGRectGetHeight(self.backgroundSkillsView.bounds) / 2);
    
    self.buttonScrollView.frame = CGRectMake(CGRectGetMinX(self.backgroundSkillsView.bounds),
                                                 CGRectGetMidY(self.backgroundSkillsView.bounds),
                                                 CGRectGetWidth(self.backgroundSkillsView.bounds),
                                                 CGRectGetHeight(self.backgroundSkillsView.bounds) / 2);
    
    CGFloat collectionViewHeight = CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.backgroundSkillsView.frame) - padding;
    self.skillsCollectionView.frame = CGRectMake(collectionViewX,
                                                 CGRectGetMaxY(self.backgroundSkillsView.frame) + padding,
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

- (void)updateLabelsWithCurrentStrings {
    
    // Set job title with format [Job Title] at [Company Title]
    NSMutableAttributedString *jobTitleString = [[NSMutableAttributedString alloc] initWithString:self.jobTitleString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                                   NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSMutableAttributedString *atString = [[NSMutableAttributedString alloc] initWithString:@" at " attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [jobTitleString appendAttributedString:atString];
    NSMutableAttributedString *companyString = [[NSMutableAttributedString alloc] initWithString:self.companyString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                                 NSForegroundColorAttributeName : [UIColor blackColor]}];
    [jobTitleString appendAttributedString:companyString];
    [self.titleLabel setAttributedText:jobTitleString];

    // Set subtitle with format [Job Location] • [Industry Title]
    NSMutableAttributedString *locationString = [[NSMutableAttributedString alloc] initWithString:self.locationString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                                   NSForegroundColorAttributeName : [UIColor blackColor]}];
    NSMutableAttributedString *dotString = [[NSMutableAttributedString alloc] initWithString:@" • " attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:8.0f],
                                                                                                                 NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [locationString appendAttributedString:dotString];
    NSMutableAttributedString *industryString = [[NSMutableAttributedString alloc] initWithString:self.industryString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:12.0f],
                                                                                                                                   NSForegroundColorAttributeName : [UIColor blackColor]}];
    [locationString appendAttributedString:industryString];
    [self.subtitleLabel setAttributedText:locationString];
    
    [self.descriptionLabel setAttributedText:[[NSAttributedString alloc] initWithString:self.descriptionString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                            NSForegroundColorAttributeName : [UIColor blackColor]}]];
    
    // Set location string on map label
    if (self.state == CPAAddJobControllerStateLocation) {
        NSMutableAttributedString *locationLabelString = [[NSMutableAttributedString alloc] initWithString:@"Move Map To Set Location\n" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0f],
                                                                                                                                                      NSForegroundColorAttributeName : [UIColor whiteColor]}];
        NSMutableAttributedString *mapLocationString = [[NSMutableAttributedString alloc] initWithString:self.locationString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                                                                                                                          NSForegroundColorAttributeName : [UIColor whiteColor]}];
        [locationLabelString appendAttributedString:mapLocationString];
        [self.mapLocationLabel setAttributedText:locationLabelString];
    }
    
    // Whever text changes, check to see if all criteria is fulfilled
    NSInteger checkInt = [self checkIfAllRequiredFieldsAreSatisfied];
    if (checkInt == 10) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.2 animations:^{
        self.mapLocationLabel.alpha = 0.0f;
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.1 animations:^{
        self.mapLocationLabel.alpha = 1.0f;
    }];
    
    // If we're currently editing locaiton of the job, change the location string
    if (self.state == CPAAddJobControllerStateLocation) {
        CLGeocoder *reverseGeo = [[CLGeocoder alloc] init];
        CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
        
        [reverseGeo reverseGeocodeLocation:centerLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            
            CLPlacemark *topResult = [placemarks objectAtIndex:0];
            NSString *addressTxt = [NSString stringWithFormat:@"%@, %@", [topResult locality], [topResult administrativeArea]];
            NSLog(@"%@",addressTxt);
            self.locationString = addressTxt;
            [self updateLabelsWithCurrentStrings];
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.jobTitleTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.jobTitleString = newString;
        
        NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
        if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
            // When you return YES from this, your field will be empty
            self.jobTitleString = @"[Job Title]";
        }
        [self updateLabelsWithCurrentStrings];
    } else if (textField == self.companyTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.companyString = newString;
        
        NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
        if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
            // When you return YES from this, your field will be empty
            self.companyString = @"[Company]";
        }
        [self updateLabelsWithCurrentStrings];
    } else if (textField == self.descriptionTextField) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        self.descriptionString = newString;
        
        NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
        if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
            // When you return YES from this, your field will be empty
            self.descriptionString = @"[Add a description...]";
        }
        [self updateLabelsWithCurrentStrings];
        // Because our description may span many lines, update layout
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutViews];
        }];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // Equate a return hit on the keyboard to pressing the forward button
    [self forwardButtonPressed];
    return YES;
}

#pragma mark - Overrides

- (void)setState:(CPAAddJobControllerState)state animated:(BOOL)animated {
    _state = state;

    // Change the page control properties based on state
    switch (self.state) {
        case CPAAddJobControllerStateJobTitle: {
            self.firstPageView.backgroundColor = [CPAConstants skyBlueColor];
            [self.jobTitleTextField becomeFirstResponder];
        } break;
        case CPAAddJobControllerStateCompany: {

            if ([self.jobTitleTextField.text length] <= 0 || self.jobTitleTextField.text == nil || [self.jobTitleTextField.text isEqual:@""] == TRUE) {
                self.firstPageView.backgroundColor = [UIColor redColor];
            } else {
                self.firstPageView.backgroundColor = [UIColor greenColor];
            }
            
            self.secondPageView.backgroundColor = [CPAConstants skyBlueColor];
            [self.companyTextField becomeFirstResponder];
            
        } break;
        case CPAAddJobControllerStateLocation: {
            [self.view endEditing:YES];
            if ([self.companyTextField.text length] <= 0 || self.companyTextField.text == nil || [self.companyTextField.text isEqual:@""] == TRUE) {
                self.secondPageView.backgroundColor = [UIColor redColor];
            } else {
                self.secondPageView.backgroundColor = [UIColor greenColor];
            }
            
            self.thirdPageView.backgroundColor = [CPAConstants skyBlueColor];
            
        } break;
        case CPAAddJobControllerStateIndustry: {
            [self.view endEditing:YES];
            if ([self.locationString isEqualToString:@"[Location]"] || [self.locationString containsString:@"(null)"]) {
                self.thirdPageView.backgroundColor = [UIColor redColor];
            } else {
                self.thirdPageView.backgroundColor = [UIColor greenColor];
            }
            self.fourthPageView.backgroundColor = [CPAConstants skyBlueColor];
        } break;
        case CPAAddJobControllerStateDescription: {
            if ([self.industryString isEqualToString:@"[Industry]"] || [self.locationString isEqualToString:@""]) {
                self.fourthPageView.backgroundColor = [UIColor redColor];
            } else {
                self.fourthPageView.backgroundColor = [UIColor greenColor];
            }
            self.fifthPageView.backgroundColor = [CPAConstants skyBlueColor];
            [self.descriptionTextField becomeFirstResponder];
        } break;
        case CPAAddJobControllerStateSkills: {
            [self.view endEditing:YES];
        }
    }
    
    if (animated) {
        [UIView animateWithDuration:0.5 animations:^{
            [self layoutViews];
        }];
    } else {
        [self layoutViews];
    }
}

- (void)setState:(CPAAddJobControllerState)state {
    [self setState:state animated:NO];
}

#pragma mark - Button Actions

- (void)forwardButtonPressed {
    switch (self.state) {
        case CPAAddJobControllerStateJobTitle: {
            [self setState:CPAAddJobControllerStateCompany animated:YES];
        } break;
        case CPAAddJobControllerStateCompany: {
            [self setState:CPAAddJobControllerStateLocation animated:YES];
            [self.view endEditing:YES];
        } break;
        case CPAAddJobControllerStateLocation: {
            [self setState:CPAAddJobControllerStateIndustry animated:YES];
        } break;
        case CPAAddJobControllerStateIndustry: {
            [self setState:CPAAddJobControllerStateDescription animated:YES];
        } break;
        case CPAAddJobControllerStateDescription: {
            
        } break;
    }
}

- (void)backButtonPressed {
    switch (self.state) {
        case CPAAddJobControllerStateJobTitle: {

        } break;
        case CPAAddJobControllerStateCompany: {
            [self setState:CPAAddJobControllerStateJobTitle animated:YES];
            if ([self.companyTextField.text length] <= 0 || self.companyTextField.text == nil || [self.companyTextField.text isEqual:@""] == TRUE) {
                self.secondPageView.backgroundColor = [UIColor redColor];
            } else {
                self.secondPageView.backgroundColor = [UIColor greenColor];
            }
        } break;
        case CPAAddJobControllerStateLocation: {
            [self setState:CPAAddJobControllerStateCompany animated:YES];
            if ([self.locationString isEqualToString:@"[Location]"] || [self.locationString containsString:@"(null)"]) {
                self.thirdPageView.backgroundColor = [UIColor redColor];
            } else {
                self.thirdPageView.backgroundColor = [UIColor greenColor];
            }
        } break;
        case CPAAddJobControllerStateIndustry: {
            [self setState:CPAAddJobControllerStateLocation animated:YES];
            [self.view endEditing:YES];
            if ([self.industryString isEqualToString:@"[Industry]"] || [self.locationString isEqualToString:@""]) {
                self.fourthPageView.backgroundColor = [UIColor redColor];
            } else {
                self.fourthPageView.backgroundColor = [UIColor greenColor];
            }
        } break;
        case CPAAddJobControllerStateDescription: {
            [self setState:CPAAddJobControllerStateIndustry animated:YES];
            if ([self.descriptionTextField.text length] <= 0 || self.descriptionTextField.text == nil || [self.descriptionTextField.text isEqual:@""] == TRUE) {
                self.fifthPageView.backgroundColor = [UIColor redColor];
            } else {
                self.fifthPageView.backgroundColor = [UIColor greenColor];
            }
        } break;
    }
}

- (void)centerLocationButtonPressed:(UIButton *)button {
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        [self startStandardUpdates];
    } else {
        MKCoordinateSpan mapSpan = MKCoordinateSpanMake(0.01, 0.01);
        [self.mapView setRegion:MKCoordinateRegionMake(self.currentLocation.coordinate, mapSpan) animated:YES];
    }
}

- (void)finishBarButtonPressed:(UIBarButtonItem *)barButton {
    
    if (self.state != CPAAddJobControllerStateSkills) {
        [self setState:CPAAddJobControllerStateSkills animated:YES];
    } else if (self.state == CPAAddJobControllerStateSkills) {
        // 1. Send job to Parse
        [self postJobToParse];
    }
}

#pragma mark - Parse Networking

- (void)postJobToParse {

    // Create a parse Post object
    PFObject *jobObject = [PFObject objectWithClassName:@"Job"];
    [jobObject setObject:[PFUser currentUser] forKey:@"user"];
    [jobObject setObject:self.jobTitleString forKey:@"title"];
    [jobObject setObject:self.companyString forKey:@"company"];
    [jobObject setObject:self.locationString forKey:@"locationString"];
    PFGeoPoint *jobGeoPoint = [PFGeoPoint geoPointWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
    [jobObject setObject:jobGeoPoint forKey:@"location"];
    [jobObject setObject:self.industryString forKey:@"industry"];
    [jobObject setObject:self.descriptionString forKey:@"description"];
    [jobObject setObject:self.jobSkillsMutableArray forKey:@"skills"];
    [jobObject setObject:self.experienceString forKey:@"experience"];
    [jobObject setObject:self.typeString forKey:@"type"];
    
    // Jobs are public, but may only be modified by the user who uploaded them
    PFACL *postACL = [PFACL ACLWithUser:[PFUser currentUser]];
    [postACL setPublicReadAccess:YES];
    jobObject.ACL = postACL;
    
    // Request a background execution task to allow us to finish uploading the post even if the app is backgrounded
    self.jobPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.jobPostBackgroundTaskId];
    }];
    
    // Save
    [jobObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Job uploaded");
            
            PFObject *jobActivityObject = [PFObject objectWithClassName:@"Activity"];
            [jobActivityObject setObject:jobObject forKey:@"post"];
            [jobActivityObject setObject:@"job" forKey:@"type"];
            [jobActivityObject setObject:[PFUser currentUser] forKey:@"fromUser"];
            [jobActivityObject setObject:[PFUser currentUser] forKey:@"toUser"];
            
            PFACL *ACL = [PFACL ACLWithUser:[PFUser currentUser]];
            [ACL setPublicReadAccess:YES];
            jobActivityObject.ACL = ACL;
            
            [jobActivityObject saveEventually];

            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.parse.Referrall.didFinishAddingJob" object:jobObject];

        } else {
            
            UIAlertController *postAlert = [UIAlertController alertControllerWithTitle:@"Job could not be uploaded" message:@"Please check you internet connection and try again" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [postAlert addAction:defaultAction];
            [self presentViewController:postAlert animated:YES completion:nil];
            
        }
        [[UIApplication sharedApplication] endBackgroundTask:self.jobPostBackgroundTaskId];
    }];
    // Send us back to the presenting VC
    [self.delegate addJobViewControllerDidComplete:self];
}

#pragma mark - Helper Methods

- (NSInteger)checkIfAllRequiredFieldsAreSatisfied {
    
    // Check if job title is filled out. If not, return the state so that whoever called this method knows what still needs to be completed
    if ([self.jobTitleString length] <= 0 || self.jobTitleString == nil || [self.jobTitleString isEqualToString:@""] == TRUE || [self.jobTitleString isEqualToString:@"[Job Title]"]) {
        return CPAAddJobControllerStateJobTitle;
    }
    
    // Check if the company title is filled out
    if ([self.companyString length] <= 0 || self.companyString == nil || [self.companyString isEqualToString:@""] == TRUE || [self.companyString isEqualToString:@"[Company]"]) {
        return CPAAddJobControllerStateCompany;
    }

    if ([self.locationString isEqualToString:@"[Location]"] || [self.locationString containsString:@"(null)"]) {
        return CPAAddJobControllerStateLocation;
    }
    
    if ([self.industryString isEqualToString:@"[Industry]"] || [self.locationString isEqualToString:@""]) {
        return CPAAddJobControllerStateIndustry;
    }
    
    if ([self.descriptionString length] <= 0 || self.descriptionString == nil || [self.descriptionString isEqualToString:@""] == TRUE || [self.descriptionString isEqualToString:@"[Add a description...]"]) {
        return CPAAddJobControllerStateDescription;
    }
    
    // If everything is filled out appropriately, return '10' (arbitrary number to let us know that we can move on
    return 10;
}

#pragma mark - CPAButtonScrollViewDelegate

- (void)buttonScrollViewButtonStringSelected:(NSString *)buttonString onButtonScrollView:(CPAButtonScrollView *)buttonScrollView {
    if (buttonScrollView == self.buttonScrollView) {
        [self updateViewsWithSkill:buttonString];
    } else if (buttonScrollView == self.industryButtonScrollView) {
        self.industryString = buttonString;
        [self updateViewsWithSkill:buttonString];
        [self.buttonScrollView centerScrollViewOnButtonWithStringTitle:buttonString];
        [self updateLabelsWithCurrentStrings];
    } else if (buttonScrollView == self.experienceButtonScrollView) {
        self.experienceString = buttonString;
    } else if (buttonScrollView == self.typeButtonScrollView) {
        self.typeString = buttonString;
    }
}

- (void)updateViewsWithSkill:(NSString *)skillString {
    if ([skillString isEqualToString:@"Accounting"]) {
        self.skillsArray = self.skills.accounting;
    } else if ([skillString isEqualToString:@"Finance"]) {
        self.skillsArray = self.skills.finance;
    }
    [self.skillsCollectionView reloadData];
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
    if ([self.jobSkillsMutableArray containsObject:self.skillsArray[indexPath.item]]) { // need to check if this is a selected cell since we reuse cells
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
        [self.jobSkillsMutableArray addObject:cell.skillString];
        
        // Update the list of skills and the reset the layout
        [self updateUserSkillListLabel];
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutViews];
        }];
    } else {
        cell.state = CPASkillsCollectionViewCellStateNotSelected;
        [self.jobSkillsMutableArray removeObject:cell.skillString];
        
        // Update the list of skills and the reset the layout
        [self updateUserSkillListLabel];
        [UIView animateWithDuration:0.2 animations:^{
            [self layoutViews];
        }];
    }
}

- (void)updateUserSkillListLabel {
    
    NSMutableString *newSkillLabelString = [[NSMutableString alloc] initWithString:@""];;
    
    for (int i = 0; i < self.jobSkillsMutableArray.count; i++) {
        
        // We only want to add a " • " to the string if there is more than 1 invite
        if (i == 0) {
            NSString *skillStringToAdd = [self.jobSkillsMutableArray objectAtIndex:i];
            [newSkillLabelString appendString:[NSString stringWithFormat:@"%@", skillStringToAdd]];
        } else {
            NSString *skillStringToAdd = [self.jobSkillsMutableArray objectAtIndex:i];
            [newSkillLabelString appendString:[NSString stringWithFormat:@" • %@", skillStringToAdd]];
        }
    }
    self.skillsListLabel.text = newSkillLabelString;
}

#pragma mark - CLLocationManagerDelegate methods and helpers

- (CLLocationManager *)locationManager {
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Check for iOS 8.
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
        }
        
        // Set a movement threshold for new events.
        _locationManager.distanceFilter = kCLLocationAccuracyNearestTenMeters;
    }
    return _locationManager;
}

- (void)startStandardUpdates {
    [self.locationManager startUpdatingLocation];
    
    CLLocation *currentLocation = self.locationManager.location;
    if (currentLocation) {
        self.currentLocation = currentLocation;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        {
            NSLog(@"kCLAuthorizationStatusAuthorized");
            [self.locationManager startUpdatingLocation];
        }
            break;
        case kCLAuthorizationStatusAuthorizedAlways:
        {
            NSLog(@"kCLAuthorizationStatusAuthorized");
            [self.locationManager startUpdatingLocation];
        }
            break;
        case kCLAuthorizationStatusDenied:
            NSLog(@"kCLAuthorizationStatusDenied");
        {
            UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:@"Cabaray can’t access your current location" message:@"To view nearby venues, turn on location access for Cabaray in the Settings app under Location Services." preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [locationAlert addAction:defaultAction];
            [self presentViewController:locationAlert animated:YES completion:nil];
            
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
        {
            NSLog(@"kCLAuthorizationStatusNotDetermined");
        }
            break;
        case kCLAuthorizationStatusRestricted:
        {
            NSLog(@"kCLAuthorizationStatusRestricted");
        }
            break;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = locations.lastObject;
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", [error description]);
    
    if (error.code == kCLErrorDenied) {
        [self.locationManager stopUpdatingLocation];
    } else if (error.code == kCLErrorLocationUnknown) {
        // todo: retry?
        // set a timer for five seconds to cycle location, and if it fails again, bail and tell the user.
    } else {
        UIAlertController *locationAlert = [UIAlertController alertControllerWithTitle:@"Error retrieving location" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [locationAlert addAction:defaultAction];
        [self presentViewController:locationAlert animated:YES completion:nil];
    }
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    // Write code to adjust views accordingly using deltaHeight
//    CGFloat deltaHeight = kbSize.height - _currentKeyboardHeight;
    _currentKeyboardHeight = kbSize.height;
}

- (void)keyboardWillHide:(NSNotification*)notification {
    // Write code to adjust views accordingly using kbSize.height
//    NSDictionary *info = [notification userInfo];
//    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    _currentKeyboardHeight = 0.0f;
}

@end
