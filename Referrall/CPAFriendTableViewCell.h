//
//  CPAFriendTableViewCell.h
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class CPAFriendTableViewCell;

@protocol CPAFriendTableViewCellDelegate <NSObject>

- (void)cell:(CPAFriendTableViewCell *)cellView didTapAddFriendButton:(PFUser *)user;

@end

@interface CPAFriendTableViewCell : UITableViewCell

@property (nonatomic, strong) id <CPAFriendTableViewCellDelegate> delegate;

// The user represented in the cell
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *jobSubtitleLabel;
@property (nonatomic, strong) UIButton *addButton;

// Static helper methods
+ (CGFloat)heightForFriendCell:(PFUser *)user width:(CGFloat)width;

@end
