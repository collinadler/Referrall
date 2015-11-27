//
//  AppDelegate.m
//  Referrall
//
//  Created by Collin Adler on 8/24/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "CPAOnboardingViewController.h"
#import "CPAOnboardingContentViewController.h"
#import "CPAHomeViewController.h"
#import "CPAConstants.h"
#import "CPACache.h"

// TODO: DELETE BELOW
#import "CPAAddFriendsViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Set up our app's global UIAppearance
    [self setupAppearance];
    
    // Initialize Parse.
    [Parse setApplicationId:@"viIK3sNC5jJkcgKAmzaqwgVsamGLxGcsPRILj41K"
                  clientKey:@"KH1umAkFrB05zuVzntzQ8I8ASyTGDAURPIhJDGjk"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    if ([PFUser currentUser]) {
        CPAHomeViewController *homeVC = [[CPAHomeViewController alloc] init];
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:homeVC];
        self.window.rootViewController = navVC;
    } else {
        UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[self setUpOnboarding]];
        self.window.rootViewController = navVC;
    }
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[ @"global" ];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    // Reset the badge count
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Facebook

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation
            ];
}

#pragma mark - ()

- (void)setupAppearance {
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:15.0f],
                                                           NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBarTintColor:[CPAConstants skyBlueColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:15.0f]}
                                                                                            forState:UIControlStateNormal];
}

#pragma mark - Log out

- (void)logOut {
    // clear cache
    [[CPACache sharedCache] clear];
    
    // Unsubscribe from push notifications by removing the user association from the current installation.
    [[PFInstallation currentInstallation] removeObjectForKey:@"user"];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Clear all caches
    [PFQuery clearAllCachedResults];
    
    // Log out
    [PFUser logOut];
    
    [self presentOnboardViewController];
    
}
#pragma mark - Set up onboard

- (CPAOnboardingViewController *)setUpOnboarding {
    
    CPAOnboardingContentViewController *firstPage = [CPAOnboardingContentViewController contentWithTitle:@"Lorem" body:@"Lorem ipsum sit dolor et omnicrom epsilon" image:nil buttonText:nil action:nil];
    
    CPAOnboardingContentViewController *secondPage = [CPAOnboardingContentViewController contentWithTitle:@"Ipsum" body:@"Lorem ipsum sit dolor et omnicrom epsilon" image:nil buttonText:nil action:nil];
    
    CPAOnboardingContentViewController *thirdPage = [CPAOnboardingContentViewController contentWithTitle:@"Dolor" body:@"Lorem ipsum sit dolor et omnicrom epsilon" image:nil buttonText:nil action:nil];
    
    CPAOnboardingContentViewController *fourthPage = [CPAOnboardingContentViewController contentWithTitle:@"Epsilon" body:@"Lorem ipsum sit dolor et omnicrom epsilon" image:nil buttonText:nil action:nil];
    
    CPAOnboardingViewController *onboardingVC = [CPAOnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"onboard"] contents:@[firstPage, secondPage, thirdPage, fourthPage]];
    onboardingVC.shouldFadeTransitions = YES;
    return onboardingVC;
    
}

- (void)presentOnboardViewController {
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:[self setUpOnboarding]];
    self.window.rootViewController = navVC;
}


@end
