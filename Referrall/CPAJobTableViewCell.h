//
//  CPAJobTableViewCell.h
//  Referrall
//
//  Created by Collin Adler on 9/24/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPAJob;

@interface CPAJobTableViewCell : UITableViewCell

// The job represented in the cell
@property (nonatomic, strong) CPAJob *job;

// Static helper methods
+ (CGFloat)heightForJobCell:(CPAJob *)job width:(CGFloat)width;


@end
