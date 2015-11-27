//
//  CPAAddJobViewController.h
//  Referrall
//
//  Created by Collin Adler on 11/6/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPAAddJobViewController;

@protocol CPAAddJobViewControllerDelegate <NSObject>

// Inform the presenting view controller when the create post is done
- (void)addJobViewControllerDidComplete:(CPAAddJobViewController *)addJobVC;

@end

@interface CPAAddJobViewController : UIViewController

@property (nonatomic, weak) NSObject <CPAAddJobViewControllerDelegate> *delegate;

@end
