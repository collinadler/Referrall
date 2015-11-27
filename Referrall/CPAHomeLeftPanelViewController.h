//
//  CPAHomeLeftPanelViewController.h
//  Referrall
//
//  Created by Collin Adler on 9/2/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPAHomeLeftPanelViewControllerDelegate <NSObject>

- (void)menuDidTapOnMyProfileButton;
- (void)menuDidTapOnMyFriendsButton;
- (void)menuDidTapOnLogOutButton;

@end

@interface CPAHomeLeftPanelViewController : UIViewController

@property (nonatomic, assign) id<CPAHomeLeftPanelViewControllerDelegate> delegate;

@end