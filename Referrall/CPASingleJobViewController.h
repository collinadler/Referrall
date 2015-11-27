//
//  CPASingleJobViewController.h
//  Referrall
//
//  Created by Collin Adler on 11/27/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPAJob;

@interface CPASingleJobViewController : UIViewController

@property (nonatomic, strong) CPAJob *job;

- (instancetype)initWithJob:(CPAJob *)job;

@end
