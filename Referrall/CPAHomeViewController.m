//
//  CPAHomeViewController.m
//  Referrall
//
//  Created by Collin Adler on 9/2/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "CPAConstants.h"
#import "CPAHomeViewController.h"
#import "CPAHomeLeftPanelViewController.h"
#import "CPAAddJobViewController.h"
#import "CPAJobTableViewCell.h"
#import "CPAJob.h"
#import "CPASingleJobViewController.h"

#define SLIDE_TIMING .25
#define PANEL_WIDTH 250
#define JOBS_PER_PAGE 20

@interface CPAHomeViewController () <CPAHomeLeftPanelViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, CPAAddJobViewControllerDelegate>

// Data array of jobs
@property (nonatomic, strong) NSMutableArray *jobsMutableArray;

// Main tableview
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

// Left slide out panel
@property (nonatomic, strong) CPAHomeLeftPanelViewController *leftPanelViewController;
@property (nonatomic, assign) BOOL showingLeftPanel;
@property (nonatomic, assign) CGFloat beginningLeftPanelX;

// Social feed properties
@property (nonatomic, assign) BOOL shouldReloadOnAppear;

// Keep track of last tracked cell for transitioning
@property (nonatomic, weak) UIView *lastTappedCellMainView;

@end

@implementation CPAHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldReloadOnAppear = NO;
    
    [self queryForJobs];
    
    self.navigationController.view.backgroundColor = [CPAConstants skyBlueColor]; // need to set the nav controller to black because it shows when we slide out the left menu
    self.view.backgroundColor = [CPAConstants lightGrayColor];
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    logoImageView.frame = CGRectMake(0, 0, 85, 30);
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoImageView;
    
    // Our left navigation button will manage the views
    self.leftBarButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 33, 33)];
    self.leftBarButton.tag = 1; // init with tag of 1
    [self.leftBarButton addTarget:self
                     action:@selector(settingsButtonPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [self.leftBarButton setBackgroundImage:[UIImage imageNamed:@"settings"]
                            forState:UIControlStateNormal];
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc] initWithCustomView:self.leftBarButton];
    self.navigationItem.leftBarButtonItem = settingsButton;
    
    UIBarButtonItem *addJobButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(addJobButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addJobButton;

    [self setupViews];
    
    [self.tableView registerClass:[CPAJobTableViewCell class] forCellReuseIdentifier:@"jobCell"];
    
    // Add notification center items here
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userAddedJob:) name:@"com.parse.Referrall.didFinishAddingJob" object:nil];
}

- (void)setupViews {

    // Main table view
    self.tableView = [UITableView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; // don't show excess cells at the bottom
    self.tableView.backgroundColor = [CPAConstants lightGrayColor];
    [self.view addSubview:_tableView];
    
    // Add refresh control to table view for pull to refresh
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView insertSubview:refreshView atIndex:0];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0f],
                                                                                                                     NSForegroundColorAttributeName : [UIColor blackColor]}];
    [self.refreshControl addTarget:self action:@selector(refreshJobs) forControlEvents:UIControlEventValueChanged];
    [refreshView addSubview:self.refreshControl];
    
    // Set up our slide out menu view
    self.leftPanelViewController = [[CPAHomeLeftPanelViewController alloc] init];
    self.leftPanelViewController.delegate = self;
    [self.view addSubview:self.leftPanelViewController.view];
    [self addChildViewController:_leftPanelViewController];
    [_leftPanelViewController didMoveToParentViewController:self];
    self.showingLeftPanel = NO;
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePanel:)];
    [panRecognizer setMinimumNumberOfTouches:1];
    [panRecognizer setMaximumNumberOfTouches:1];
    [self.leftPanelViewController.view addGestureRecognizer:panRecognizer];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldReloadOnAppear) {
        self.shouldReloadOnAppear = NO;
        [self queryForJobs];
    }
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"com.parse.Referrall.didFinishAddingJob" object:nil];
}

#pragma mark - Overrides

- (void)setShowingLeftPanel:(BOOL)showingLeftPanel {
    [self setShowingLeftPanel:showingLeftPanel animated:NO];
}

- (void)setShowingLeftPanel:(BOOL)showingLeftPanel animated:(BOOL)animated {
    _showingLeftPanel = showingLeftPanel;
    if (animated) {
        
        if (showingLeftPanel) {
            
            // move left panel to the right
            [self.view bringSubviewToFront:self.leftPanelViewController.view];
            [self.leftPanelViewController.view.layer setShadowColor:[CPAConstants skyBlueColor].CGColor];
            [self.leftPanelViewController.view.layer setShadowOpacity:0.7];
            [self.leftPanelViewController.view.layer setShadowOffset:CGSizeMake(5, 5)];
            [UIView animateWithDuration:SLIDE_TIMING animations:^{
                self.leftPanelViewController.view.frame = CGRectMake(0, 0, PANEL_WIDTH, self.view.frame.size.height);
                self.navigationController.navigationBar.frame = CGRectMake(PANEL_WIDTH, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
                
            }];
            
        } else {
            
            [self.leftPanelViewController.view.layer setShadowOffset:CGSizeMake(0, 0)];
            // Move panel to original position
            [UIView animateWithDuration:SLIDE_TIMING animations:^{
                self.leftPanelViewController.view.frame = CGRectMake(CGRectGetMinX(self.view.frame) - PANEL_WIDTH, 0, PANEL_WIDTH, self.view.frame.size.height);
                self.navigationController.navigationBar.frame = CGRectMake(CGRectGetMinX(self.view.frame), self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
            }];
        }
    } else {
        if (showingLeftPanel) {
            
            // move left panel to the right
            [self.view bringSubviewToFront:self.leftPanelViewController.view];
            [self.leftPanelViewController.view.layer setShadowColor:[CPAConstants skyBlueColor].CGColor];
            [self.leftPanelViewController.view.layer setShadowOpacity:0.7];
            [self.leftPanelViewController.view.layer setShadowOffset:CGSizeMake(5, 5)];
            
            self.leftPanelViewController.view.frame = CGRectMake(0, 0, PANEL_WIDTH, self.view.frame.size.height);
            self.navigationController.navigationBar.frame = CGRectMake(PANEL_WIDTH, self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        } else {
            
            [self.leftPanelViewController.view.layer setShadowOffset:CGSizeMake(0, 0)];
            // Move panel to original position
            self.leftPanelViewController.view.frame = CGRectMake(CGRectGetMinX(self.view.frame) - PANEL_WIDTH, 0, PANEL_WIDTH, self.view.frame.size.height);
            self.navigationController.navigationBar.frame = CGRectMake(CGRectGetMinX(self.view.frame), self.navigationController.navigationBar.frame.origin.y, self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
        }
    }
}

#pragma mark - Parse

- (void)queryForJobs {
    
    if (![PFUser currentUser]) {
        return;
    }
    
    PFQuery *followingActivitiesQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingActivitiesQuery whereKey:@"type" equalTo:@"follow"];
    [followingActivitiesQuery whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    followingActivitiesQuery.limit = 1000;
    
    PFQuery *jobsFromFollowedUsersQuery = [PFQuery queryWithClassName:@"Job"];
    [jobsFromFollowedUsersQuery whereKey:@"user" matchesKey:@"toUser" inQuery:followingActivitiesQuery];
    
    PFQuery *jobsFromCurrentUserQuery = [PFQuery queryWithClassName:@"Job"];
    [jobsFromCurrentUserQuery whereKey:@"user" equalTo:[PFUser currentUser]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:[NSArray arrayWithObjects:jobsFromFollowedUsersQuery, jobsFromCurrentUserQuery, nil]];
    [query setLimit:JOBS_PER_PAGE];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"error in event query!: %@ -or- %@ ", error.localizedDescription, error.debugDescription); // TODO: why would this happen? - do we need an alert?
            // If our refresh control is refreshing, end it
            if (self.refreshControl.refreshing) {
                [self.refreshControl endRefreshing];
            }
        } else {
            NSMutableArray *newJobs = [[NSMutableArray alloc] initWithCapacity:objects.count];
            for (PFObject *object in objects) {
                CPAJob *newJob = [[CPAJob alloc] initWithObject:object];
                [newJobs addObject:newJob];
            }
            _jobsMutableArray = newJobs;
            
            // If our refresh control is refreshing, end it
            if (self.refreshControl.refreshing) {
                [self.refreshControl endRefreshing];
            }

        }
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1; // Always have 1 section
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"COUNT: %lu", (unsigned long)self.jobsMutableArray.count);
    return self.jobsMutableArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CPAJobTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"jobCell"];
    if (cell == nil) {
        cell = [[CPAJobTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"jobCell"];
    }
    cell.job = self.jobsMutableArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CPAJobTableViewCell *cell = (CPAJobTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    CPASingleJobViewController *singleJobVC = [[CPASingleJobViewController alloc] initWithJob:cell.job];
    [self.navigationController pushViewController:singleJobVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CPAJob *job = self.jobsMutableArray[indexPath.row];
    return [CPAJobTableViewCell heightForJobCell:job width:CGRectGetWidth(self.view.frame)];
}

#pragma mark - Gestures

-(void)movePanel:(UIPanGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.beginningLeftPanelX = self.leftPanelViewController.view.frame.origin.x;
    }
    
    // Change the overlayView's rect while in the midst of panning
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        CGPoint translation = [recognizer translationInView:self.leftPanelViewController.view];
        
        CGFloat existingPanelHeight = CGRectGetHeight(self.leftPanelViewController.view.frame);
        CGFloat startingX = self.leftPanelViewController.view.frame.origin.x;
        CGFloat minLeftPanelX = CGRectGetMinX(self.view.frame) - PANEL_WIDTH;
        CGFloat maxLeftPanelX = CGRectGetMinX(self.view.frame);
        CGFloat newX = MAX(minLeftPanelX, MIN((startingX + translation.x), maxLeftPanelX));
        
        CGRect potentialNewFrame = CGRectMake(newX,
                                              CGRectGetMinY(self.view.bounds
                                                            ),
                                              PANEL_WIDTH,
                                              existingPanelHeight);
        
        self.leftPanelViewController.view.frame = potentialNewFrame;
        
        // Also need to simultaneously move the nav bar
        CGRect existingNavBarRect = self.navigationController.navigationBar.frame;
        CGFloat startingNavBarX = self.navigationController.navigationBar.frame.origin.x;
        CGFloat minNavBarX = CGRectGetMinX(self.view.frame);
        CGFloat maxNavBarX = CGRectGetMinX(self.view.frame) + PANEL_WIDTH;
        CGFloat newNavBarX = MAX(minNavBarX, MIN((startingNavBarX + translation.x), maxNavBarX));
        self.navigationController.navigationBar.frame = CGRectMake(newNavBarX,
                                                                   existingNavBarRect.origin.y,
                                                                   existingNavBarRect.size.width,
                                                                   existingNavBarRect.size.height);
        
    }
    [recognizer setTranslation:CGPointZero inView:self.leftPanelViewController.view];
    
    // If the user stops panning at some point, pop the event view into either of its two states - don't let it remain in between
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.showingLeftPanel) {
            
            if (self.beginningLeftPanelX - self.leftPanelViewController.view.frame.origin.x < 25) { // if we only moved the left frame a little, snap it back to its original position
                [self setShowingLeftPanel:YES animated:YES];
            } else {
                [self setShowingLeftPanel:NO animated:YES];
            }
        }
    }
}

#pragma mark - Control Helpers

- (void)settingsButtonPressed:(UIBarButtonItem *)button {
    if (self.showingLeftPanel) {
        [self setShowingLeftPanel:NO animated:YES];
    } else {
        [self setShowingLeftPanel:YES animated:YES];
    }
}

- (void)addJobButtonPressed:(UIBarButtonItem *)button {
    CPAAddJobViewController *jobVC = [[CPAAddJobViewController alloc] init];
    jobVC.delegate = self;
    [self.navigationController pushViewController:jobVC animated:YES];
}

- (void)refreshJobs {
    NSLog(@"REFRESHING!");
    [self.refreshControl beginRefreshing];
    [self queryForJobs];
}


#pragma mark - CPAAddJobViewControllerDelegate

- (void)addJobViewControllerDidComplete:(CPAAddJobViewController *)addJobVC {
    [self.navigationController popToViewController:self animated:YES];
}

#pragma mark - CPALeftPanelViewControllerDelegate

- (void)menuDidTapOnMyProfileButton {
    // First, normalize the nav bar
    [self setShowingLeftPanel:NO animated:YES];
    NSLog(@"profile button pressed");
    PFQuery *query = [PFUser query];
    [query getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *object, NSError *error) {
        if (!error) {
//            PFUser *signedInUser = (PFUser *)object;
//            CABProfileViewController *profileVC = [[CABProfileViewController alloc] initWithUser:signedInUser];
//            [self.navigationController pushViewController:profileVC animated:YES];
        } else {
//            CABProfileViewController *profileVC = [[CABProfileViewController alloc] initWithUser:[PFUser currentUser]];
//            [self.navigationController pushViewController:profileVC animated:YES];
        }
    }];
}

- (void)menuDidTapOnMyFriendsButton {
    // First, normalize the nav bar
    [self setShowingLeftPanel:NO animated:YES];
    NSLog(@"friends button pressed");
//    CABFriendsViewController *friendsVC = [[CABFriendsViewController alloc] init];
//    [self.navigationController pushViewController:friendsVC animated:YES];
}

- (void)menuDidTapOnLogOutButton {
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] logOut];
}

#pragma mark - Notification Center

- (void)userAddedJob:(NSNotification *)note {
    self.shouldReloadOnAppear = YES;
}

@end
