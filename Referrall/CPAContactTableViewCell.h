//
//  CPAContactTableViewCell.h
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPAContact.h"
@class CPAContactTableViewCell;

@protocol CPAContactTableViewCellDelegate <NSObject>

- (void)cell:(CPAContactTableViewCell *)cellView didTapInviteButton:(CPAContact *)contact;

@end

@interface CPAContactTableViewCell : UITableViewCell

@property (nonatomic, strong) id <CPAContactTableViewCellDelegate> delegate;

// The contact represented in the cell
@property (nonatomic, strong) CPAContact *contact;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userSubtitleLabel;
@property (nonatomic, strong) UIButton *inviteButton;

// Static helper methods
+ (CGFloat)heightForContactCell:(CPAContact *)contact width:(CGFloat)width;

@end
