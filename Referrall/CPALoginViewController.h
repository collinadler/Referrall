//
//  CPALoginViewController.h
//  Referrall
//
//  Created by Collin Adler on 8/24/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CPALoginViewControllerState) {
    CPALoginViewControllerStateLogin,
    CPALoginViewControllerStateSignUp
};

@interface CPALoginViewController : UIViewController

// Have a state to determine whether the VC is in login or sign up mode
@property (nonatomic, assign) CPALoginViewControllerState state;

@end
