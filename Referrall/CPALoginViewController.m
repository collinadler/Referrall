//
//  CPALoginViewController.m
//  Referrall
//
//  Created by Collin Adler on 8/24/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPALoginViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <Parse/Parse.h>
#import "CPAEditProfileViewController.h"
#import "CPAHomeViewController.h"
#import "CPAConstants.h"
#import "CPAInsetTextField.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"
@import Accelerate;

@interface CPALoginViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIImage *backgroundImage;

@property (nonatomic, strong) UIScrollView *scrollView;

// Views
@property (nonatomic, strong) UIView *textFieldBackgroundView;
@property (nonatomic, strong) CPAInsetTextField *firstNameField;
@property (nonatomic, strong) CPAInsetTextField *lastNameField;
@property (nonatomic, strong) CPAInsetTextField *emailField;
@property (nonatomic, strong) CPAInsetTextField *passwordField;

@property (nonatomic, strong) UIButton *loginOrSignupButton;
@property (nonatomic, strong) UILabel *orLabel;
@property (nonatomic, strong) FBSDKLoginButton *facebookButton;
//@property (nonatomic, strong) UIButton *facebookButton;

@property (nonatomic, strong) UILabel *switchStateLabel;
@property (nonatomic, strong) UITapGestureRecognizer *switchTap;

@property (nonatomic, strong) UILabel *forgotPasswordLabel;
@property (nonatomic, strong) UITapGestureRecognizer *forgotPasswordTap;

@property (nonatomic, strong) UITapGestureRecognizer *mainViewTap;

@property (nonatomic, strong) UIImage *profileImage;

@end

@implementation CPALoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Create the background view
    self.backgroundImage = [UIImage imageNamed:@"onboard"];
//    [self blurBackground];
    UIImageView *backgroundImageView;
    
    // create the background image view and set it to aspect fill so it isn't skewed
    if (self.backgroundImage) {
        backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [backgroundImageView setImage:self.backgroundImage];
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
    
    self.textFieldBackgroundView = [[UIView alloc] init];
    self.textFieldBackgroundView.backgroundColor = [UIColor lightGrayColor];
    
    self.firstNameField = [[CPAInsetTextField alloc] init];
    self.firstNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"First Name" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                      NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.firstNameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.firstNameField setTextColor:[CPAConstants skyBlueColor]];
    self.firstNameField.backgroundColor = [UIColor whiteColor];
    
    self.lastNameField = [[CPAInsetTextField alloc] init];
    self.lastNameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Last Name" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                      NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.lastNameField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.lastNameField setTextColor:[CPAConstants skyBlueColor]];
    self.lastNameField.backgroundColor = [UIColor whiteColor];

    self.emailField = [[CPAInsetTextField alloc] init];
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                      NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.emailField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.emailField setTextColor:[CPAConstants skyBlueColor]];
    self.emailField.backgroundColor = [UIColor whiteColor];

    self.passwordField = [[CPAInsetTextField alloc] init];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                                      NSForegroundColorAttributeName : [UIColor lightGrayColor]}];
    [self.passwordField setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
    [self.passwordField setTextColor:[CPAConstants skyBlueColor]];
    self.passwordField.backgroundColor = [UIColor whiteColor];
    self.passwordField.secureTextEntry = YES;
    self.passwordField.delegate = self;
    
    self.loginOrSignupButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginOrSignupButton.backgroundColor = [CPAConstants skyBlueColor];
    self.loginOrSignupButton.layer.cornerRadius = 3;
    
    self.orLabel = [[UILabel alloc] init];
    self.orLabel.attributedText = [[NSAttributedString alloc] initWithString:@"or"
                                                                           attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.orLabel.textAlignment = NSTextAlignmentCenter;
    
    self.facebookButton = [[FBSDKLoginButton alloc] init];
    [self.facebookButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; // remove existing action on FB's button to replace with Parse's method
    [self.facebookButton addTarget:self action:@selector(loginWithFacebook:) forControlEvents:UIControlEventTouchUpInside];
    
    self.switchStateLabel = [[UILabel alloc] init];
    self.switchStateLabel.userInteractionEnabled = YES;
    self.switchTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchTapFired:)];
    [self.switchStateLabel addGestureRecognizer:self.switchTap];

    self.forgotPasswordLabel = [[UILabel alloc] init];
    self.forgotPasswordLabel.userInteractionEnabled = YES;
    self.forgotPasswordLabel.textAlignment = NSTextAlignmentLeft;
    self.forgotPasswordLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Forgot password?"
                                                                           attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                        NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.forgotPasswordTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPasswordTapFired:)];
    [self.forgotPasswordLabel addGestureRecognizer:self.forgotPasswordTap];
    
    self.mainViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                               action:@selector(mainViewTapFired:)];
    [self.view addGestureRecognizer:self.mainViewTap];
    
    [self updateViewContent];
    
    for (UIView *view in @[self.textFieldBackgroundView, self.firstNameField, self.lastNameField, self.emailField, self.passwordField, self.orLabel, self.facebookButton, self.forgotPasswordLabel, self.switchStateLabel, self.loginOrSignupButton]) {
        [self.scrollView addSubview:view];
    }
    
    self.profileImage = [[UIImage alloc] init]; // we pass the FB profile image here if we retrieve one
    
    // Register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateViewContent {
    
    switch (self.state) {
        case CPALoginViewControllerStateLogin: {
            
            // "Already have an account" label
            self.switchStateLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Join now"
                                                                                   attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                NSForegroundColorAttributeName : [UIColor whiteColor]}];
            self.switchStateLabel.textAlignment = NSTextAlignmentRight;
            self.forgotPasswordLabel.hidden = NO;
            
            // Login / sign up button
            [self.loginOrSignupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Sign in" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f],
                                                                                                                            NSForegroundColorAttributeName : [UIColor whiteColor]}]
                                                forState:UIControlStateNormal];
            [self.loginOrSignupButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [self.loginOrSignupButton addTarget:self action:@selector(loginButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
        } break;
        case CPALoginViewControllerStateSignUp: {
            
            // "Already have an account" label
            self.switchStateLabel.attributedText = [[NSAttributedString alloc] initWithString:@"Already have an account? Sign in"
                                                                                   attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                NSForegroundColorAttributeName : [UIColor whiteColor]}];
            self.switchStateLabel.textAlignment = NSTextAlignmentCenter;
            self.forgotPasswordLabel.hidden = YES;
            
            // Login / Sign up button
            [self.loginOrSignupButton setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Join now" attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:14.0f],
                                                                                                                            NSForegroundColorAttributeName : [UIColor whiteColor]}]
                                                forState:UIControlStateNormal];
            [self.loginOrSignupButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
            [self.loginOrSignupButton addTarget:self action:@selector(signupButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        } break;
    }
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.scrollView.frame = self.view.bounds;
    
    CGFloat padding = 5;
    CGFloat textFieldHeight = 35;
    CGFloat textFieldBorder = 1;
    CGFloat textFieldWidth = CGRectGetWidth(self.view.bounds) - (padding * 2) - (textFieldBorder * 2); // subtract two for the border
    CGFloat topBarPadding = 65;
    
    self.firstNameField.frame = CGRectMake(padding + textFieldBorder,
                                           topBarPadding + textFieldBorder,
                                           textFieldWidth,
                                           textFieldHeight);
    
    self.lastNameField.frame = CGRectMake(padding + textFieldBorder,
                                          CGRectGetMaxY(self.firstNameField.frame) + textFieldBorder,
                                          textFieldWidth,
                                          textFieldHeight);

    
    [self layoutViews];
}

- (void)layoutViews {
    
    CGFloat emailYOffset = 0.f;
    CGFloat backgroundViewHeight = 0.f;
    CGFloat padding = 5;
    CGFloat textFieldBorder = 1;
    CGFloat textFieldHeight = 35;
    CGFloat textFieldWidth = CGRectGetWidth(self.view.bounds) - (padding * 2) - (textFieldBorder * 2); // subtract two for the border
    CGFloat topBarPadding = 65;

    switch (self.state) {
        case CPALoginViewControllerStateLogin: {
            
            backgroundViewHeight = (textFieldHeight * 2) + (textFieldBorder * 3); // make it as large as the text fields plus a border
            emailYOffset = topBarPadding + textFieldBorder;
        
        } break;
        case CPALoginViewControllerStateSignUp: {

            backgroundViewHeight = (textFieldHeight * 4) + (textFieldBorder * 5); // make it as large as the text fields plus a border
            emailYOffset = CGRectGetMaxY(self.lastNameField.frame) + textFieldBorder;
            
        } break;
    }
    
    self.textFieldBackgroundView.frame = CGRectMake(padding,
                                                    topBarPadding,
                                                    CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                    backgroundViewHeight);
    
    self.emailField.frame = CGRectMake(padding + textFieldBorder,
                                       emailYOffset,
                                       textFieldWidth,
                                       textFieldHeight);
    
    self.passwordField.frame = CGRectMake(padding + textFieldBorder,
                                          CGRectGetMaxY(self.emailField.frame) + textFieldBorder,
                                          textFieldWidth,
                                          textFieldHeight);
    
    self.loginOrSignupButton.frame = CGRectMake(padding,
                                                CGRectGetMaxY(self.passwordField.frame) + (padding * 2),
                                                CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                textFieldHeight);
    
    CGSize maxOrLabelSize = CGSizeMake(CGRectGetWidth(self.view.bounds) - (padding * 2), CGFLOAT_MAX);
    CGSize orLabelSize = [self.orLabel sizeThatFits:maxOrLabelSize];
    self.orLabel.frame = CGRectMake(padding,
                                    CGRectGetMaxY(self.loginOrSignupButton.frame) + (padding * 2),
                                    CGRectGetWidth(self.view.bounds) - (padding * 2),
                                    orLabelSize.height);
    
    self.facebookButton.frame = CGRectMake(padding,
                                           CGRectGetMaxY(self.orLabel.frame) + (padding * 2),
                                           CGRectGetWidth(self.view.bounds) - (padding * 2),
                                           textFieldHeight);

    // Layout the remaining views based on the state and what is / isn't available
    switch (self.state) {
        case CPALoginViewControllerStateLogin: {
        


            self.forgotPasswordLabel.frame = CGRectMake(padding,
                                                        CGRectGetMaxY(self.facebookButton.frame) + padding,
                                                        (CGRectGetWidth(self.view.bounds) - (padding * 2)) / 2,
                                                        textFieldHeight);
            
            self.switchStateLabel.frame = CGRectMake(CGRectGetMaxX(self.forgotPasswordLabel.frame),
                                                     CGRectGetMaxY(self.facebookButton.frame) + padding,
                                                     (CGRectGetWidth(self.view.bounds) - (padding * 2)) / 2,
                                                     textFieldHeight);
            
        } break;
        case CPALoginViewControllerStateSignUp: {

            self.switchStateLabel.frame = CGRectMake(padding,
                                                     CGRectGetMaxY(self.facebookButton.frame) + padding,
                                                     CGRectGetWidth(self.view.bounds) - (padding * 2),
                                                     textFieldHeight);
            
            self.forgotPasswordLabel.frame = CGRectMake(padding,
                                                        CGRectGetMaxY(self.facebookButton.frame) + padding,
                                                        (CGRectGetWidth(self.view.bounds) - (padding * 2)) / 2,
                                                        textFieldHeight);
        } break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // The code below sets a tranlucent navigation bar
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Overrides

- (void)setState:(CPALoginViewControllerState)state {
    [self setState:state animated:NO];
}

- (void)setState:(CPALoginViewControllerState)state animated:(BOOL)animated {
    _state = state;
    if (animated) {
        [UIView animateWithDuration:0.4 animations:^{
            [self layoutViews];
            [self updateViewContent];
        } completion:^(BOOL finished) {
            // Make any post-animation changes (change button text and action)
        }];
        
    } else {
        [self layoutViews];
    }
}

#pragma mark - Button Actions

- (void)loginWithFacebook:(UIButton *)button {
    
    NSArray *readPermissions = @[@"public_profile", @"email", @"user_friends"];
    // Login PFUser using Facebook
    [PFFacebookUtils logInInBackgroundWithReadPermissions:readPermissions block:^(PFUser *user, NSError *error) {

        // Was login successful ?
        if (!user) {
            if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
            } else {
                NSLog(@"An error occurred: %@", error.localizedDescription);
            }
        } else {
            if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");

                // Retrieve and store the user's FB ID
                FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me" parameters:@{@"fields" : @"email, first_name, last_name, picture"} HTTPMethod:@"GET"];
                [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                    [[PFUser currentUser] setObject:[result objectForKey:@"id"] forKey:@"facebookID"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"username"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"first_name"] forKey:@"firstName"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"last_name"] forKey:@"lastName"];
                    
                    // Save the user's picture
                    NSString *pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [result objectForKey:@"id"]];
                    NSData  *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:pictureURL]];
                    if (data) {
                        self.profileImage = [UIImage imageWithData:data]; // save the image for access later
                        UIImage *mediumImage = [self.profileImage thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
                        UIImage *smallRoundedImage = [self.profileImage thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
                        NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.65); // using JPEG for larger pictures
                        NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
                        
                        if (mediumImageData.length > 0) {
                            PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
                            [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    NSLog(@"Uploaded Medium Profile Picture");
                                    [[PFUser currentUser] setObject:fileMediumImage forKey:@"profilePictureMedium"];
                                    [[PFUser currentUser] saveEventually];
                                }
                            }];
                        }
                        
                        if (smallRoundedImageData.length > 0) {
                            PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
                            [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                if (!error) {
                                    NSLog(@"Uploaded Profile Picture Thumbnail");
                                    [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:@"profilePictureSmall"];
                                    [[PFUser currentUser] saveEventually];
                                }
                            }];
                        }
                    }
                    
                    // After updating the Parse user as much as we can, send the user to the Edit Profile VC and pass the image if we have one
                    
                    CPAEditProfileViewController *profileVC = [[CPAEditProfileViewController alloc] initWithImage:self.profileImage];
                    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
                    [self presentViewController:navVC animated:YES completion:nil];
                }];

            } else {
                NSLog(@"User logged in through Facebook!");
                CPAHomeViewController *homeVC = [[CPAHomeViewController alloc] init];
                UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
                [self presentViewController:navVC animated:YES completion:nil];
            }
        }
    }];
}


- (void)loginButtonPressed:(UIButton *)sender {
    
    if (![self validateEmail:self.emailField.text]) {
        UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:@"Invalid Email"
                                                                            message:@"Please enter a valid email address"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [emailAlert addAction:defaultAction];
        [self presentViewController:emailAlert animated:YES completion:nil];
        return;
    }
    
    if (self.passwordField.text.length < 1) {
        UIAlertController *passwordAlert = [UIAlertController alertControllerWithTitle:@"Invalid Password"
                                                                               message:@"Please enter a valid password"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [passwordAlert addAction:defaultAction];
        [self presentViewController:passwordAlert animated:YES completion:nil];
        return;
    }
    
    // Show HUD view
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFUser logInWithUsernameInBackground:[self.emailField.text lowercaseString] password:self.passwordField.text block:^(PFUser *user, NSError *error) {
        if (user) {
            // Hide HUD view
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"SUCCESSFUL LOG IN");
            
        } else {
            
            // Hide HUD view
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSString *alertTitle = nil;
            
            if (error) {
                // Something else went wrong
                alertTitle = [error userInfo][@"error"];
            } else {
                // the username or password is probably wrong.
                alertTitle = @"Couldn’t log in:\nThe username or password were wrong.";
            }
            
            UIAlertController *loginAlert = [UIAlertController alertControllerWithTitle:alertTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [loginAlert addAction:defaultAction];
            [self presentViewController:loginAlert animated:YES completion:nil];
            
        }
    }];
}

- (void)signupButtonPressed:(UIButton *)sender {
    
    if (self.passwordField.text.length < 6) {
        UIAlertController *passwordAlert = [UIAlertController alertControllerWithTitle:@"Invalid Password"
                                                                               message:@"Your password must contain at least six characters"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [passwordAlert addAction:defaultAction];
        [self presentViewController:passwordAlert animated:YES completion:nil];
        return;
    }
    
    if (![self validateEmail:self.emailField.text]) {
        UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:@"Invalid Email"
                                                                            message:@"Please enter a valid email address"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
        [emailAlert addAction:defaultAction];
        [self presentViewController:emailAlert animated:YES completion:nil];
        return;
    }
    
    PFUser *user = [PFUser user];
    user.username = [self.emailField.text lowercaseString];
    user.password = self.passwordField.text;
    user.email = [self.emailField.text lowercaseString];
    [user setObject:self.firstNameField.text forKey:@"firstName"];
    [user setObject:self.lastNameField.text forKey:@"lastName"];
    
    // Show HUD view
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            // Hide HUD view
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSLog(@"USER SIGNED UP");
            CPAEditProfileViewController *profileVC = [[CPAEditProfileViewController alloc] initWithImage:nil];
            UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:profileVC];
            [self presentViewController:navVC animated:YES completion:nil];
            
        } else {
            // Hide HUD view
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSString *errorString = [error userInfo][@"error"];
            UIAlertController *signUpAlert = [UIAlertController alertControllerWithTitle:@"Invalid Sign Up"
                                                                                 message:errorString
                                                                          preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Return" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [signUpAlert addAction:defaultAction];
            [self presentViewController:signUpAlert animated:YES completion:nil];
            
        }
    }];
}

-(BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,8}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];    //  return 0;
    return [emailTest evaluateWithObject:candidate];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.passwordField) {
        [self.view endEditing:YES];
    }
    return YES;
}

#pragma mark - Gestures

- (void)switchTapFired:(UITapGestureRecognizer *)sender {
    NSLog(@"switch");
    switch (self.state) {
        case CPALoginViewControllerStateLogin: {
            
            [self setState:CPALoginViewControllerStateSignUp animated:YES];
            
        } break;
        case CPALoginViewControllerStateSignUp: {
            
            [self setState:CPALoginViewControllerStateLogin animated:YES];
            
        } break;
    }
}

- (void)forgotPasswordTapFired:(UITapGestureRecognizer *)sender {
    UIAlertController *forgotPasswordAlert = [UIAlertController alertControllerWithTitle:@"Reset Password"
                                                                                 message:@"Please enter your Referrall email address below"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
    
    [forgotPasswordAlert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Email";
        textField.keyboardType = UIKeyboardTypeEmailAddress;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {}]; // this just removes the alert with no changes
    [forgotPasswordAlert addAction:cancelAction];
    
    UIAlertAction *resetAction = [UIAlertAction actionWithTitle:@"Reset" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        UITextField *forgotPasswordTextField = [forgotPasswordAlert.textFields objectAtIndex:0];
        [PFUser requestPasswordResetForEmailInBackground:forgotPasswordTextField.text block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                UIAlertController *returnAlert = [UIAlertController alertControllerWithTitle:@"Check Email"
                                                                                     message:@"Please check your email for instructions to reset your Referrall password."
                                                                              preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [returnAlert addAction:OKAction];
                
                [self presentViewController:returnAlert animated:YES completion:nil];
                
            } else {
                UIAlertController *notFoundAlert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                                       message:@"Could not locate an account with the specified email. Please try again."
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *OKAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
                [notFoundAlert addAction:OKAction];
                
                [self presentViewController:notFoundAlert animated:YES completion:nil];
                
            }
        }];
    }];
    [forgotPasswordAlert addAction:resetAction];
    [self presentViewController:forgotPasswordAlert animated:YES completion:nil];
}

- (void) mainViewTapFired:(UIGestureRecognizer *)sender {
    [self.view endEditing:YES];
}

#pragma mark - Image blurring

- (void)blurBackground {
    // Check pre-conditions.
    if (self.backgroundImage.size.width < 1 || self.backgroundImage.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.backgroundImage.size.width, self.backgroundImage.size.height, self.backgroundImage);
        return;
    }
    if (!self.backgroundImage.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self.backgroundImage);
        return;
    }
    
    UIColor *tintColor = [UIColor colorWithWhite:0.7 alpha:0.3];
    CGFloat blurRadius = 20.0f; // YOU CAN EDIT THIS FOR THE DESIRED EFFECT
    CGFloat saturationDeltaFactor = 1.8f; // YOU CAN EDIT THIS FOR THE DESIRED EFFECT
    CGRect imageRect = { CGPointZero, self.backgroundImage.size };
    UIImage *effectImage = self.backgroundImage;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.backgroundImage.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.backgroundImage.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.backgroundImage.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.backgroundImage.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            unsigned int radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.backgroundImage.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.backgroundImage.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.backgroundImage.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.backgroundImage = outputImage;
}

#pragma mark - Keyboard Handling

- (void)keyboardWillShow:(NSNotification *)notifcation {
    
    NSDictionary *info = [notifcation userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    // If the bottom button is hidden by the keyboard, scroll it so that it's visible
    CGRect rect = self.view.frame;
    rect.size.height -= keyboardSize.height;
    CGPoint origin = CGPointMake(0, CGRectGetMaxY(self.switchStateLabel.frame));
    if (!CGRectContainsPoint(rect, origin)) {
        CGPoint scrollPoint = CGPointMake(0.0, CGRectGetMaxY(self.switchStateLabel.frame) + CGRectGetHeight(self.switchStateLabel.frame) - (rect.size.height));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

@end
