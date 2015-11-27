//
//  CPAContactTableViewCell.m
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAContactTableViewCell.h"
#import "CPAConstants.h"

@interface CPAContactTableViewCell ()

@property (nonatomic, strong) UIView *mainView;

@end

@implementation CPAContactTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self.contentView setBackgroundColor:[CPAConstants lightGrayColor]];
        
        self.mainView = [[UIView alloc] init];
        self.mainView.backgroundColor = [UIColor whiteColor];
        self.mainView.layer.shadowOpacity = 0.15;
        self.mainView.layer.shadowOffset = CGSizeMake(1.0, 1.2);
        self.mainView.layer.shadowRadius = 1.0;
        [self.contentView addSubview:self.mainView];
        
        self.nameLabel = [[UILabel alloc] init];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.nameLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f]];
        [self.nameLabel setTextColor:[UIColor blackColor]];
        [self.nameLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.mainView addSubview:self.nameLabel];
        
        self.userSubtitleLabel = [[UILabel alloc] init];
        [self.userSubtitleLabel setBackgroundColor:[UIColor clearColor]];
        [self.userSubtitleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f]];
        [self.userSubtitleLabel setTextColor:[UIColor lightGrayColor]];
        [self.userSubtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self.mainView addSubview:self.userSubtitleLabel];
        
        self.inviteButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.inviteButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f]];
        [self.inviteButton setTitleColor:[CPAConstants skyBlueColor] forState:UIControlStateNormal];
        [self.inviteButton.titleLabel setTextColor:[CPAConstants skyBlueColor]];
        [self.inviteButton setBackgroundColor:[UIColor clearColor]];
        [self.inviteButton setTitle:@"Invite" forState:UIControlStateNormal];
        [self.inviteButton.layer setBorderColor:[CPAConstants skyBlueColor].CGColor];
        [self.inviteButton.layer setBorderWidth:1];
        [self.inviteButton.layer setCornerRadius:3];
        [self.inviteButton addTarget:self action:@selector(inviteButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.inviteButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat inviteButtonWidth = 55;
    CGFloat inviteButtonHeight = 25;
    CGFloat cellPadding = 10;
    CGFloat padding = 7.5;
    CGFloat mainViewHeight = 50;
    
    self.mainView.frame = CGRectMake(cellPadding,
                                     cellPadding,
                                     CGRectGetWidth(self.bounds) - (cellPadding * 2),
                                     mainViewHeight);
    
    // Main view subviews
    self.inviteButton.frame = CGRectMake(CGRectGetMaxX(self.mainView.bounds) - inviteButtonWidth - (padding * 2),
                                         CGRectGetMidY(self.mainView.bounds) - inviteButtonHeight / 2,
                                         inviteButtonWidth,
                                         inviteButtonHeight);
    
    // Get the total height of the labels
    CGSize maxNameLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - inviteButtonWidth - (padding * 4), CGFLOAT_MAX);
    CGSize nameLabelSize = [self.nameLabel sizeThatFits:maxNameLabelSize];
    CGSize maxSubtitleLabelSize = CGSizeMake(CGRectGetWidth(self.mainView.frame) - inviteButtonWidth - (padding * 4), CGFLOAT_MAX);
    CGSize subtitleLabelSize = [self.userSubtitleLabel sizeThatFits:maxSubtitleLabelSize];
    CGFloat totalLabelHeight = nameLabelSize.height + subtitleLabelSize.height;

    self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                      CGRectGetMidY(self.mainView.bounds) - totalLabelHeight / 2,
                                      nameLabelSize.width,
                                      nameLabelSize.height);
    
    self.userSubtitleLabel.frame = CGRectMake(CGRectGetMinX(self.mainView.bounds) + padding,
                                              CGRectGetMaxY(self.nameLabel.frame),
                                              subtitleLabelSize.width,
                                              subtitleLabelSize.height);
    
}

#pragma mark - Overrides

- (void)setContact:(CPAContact *)contact {
    _contact = contact;
    
    // Set name
    if (self.contact.lastName == (id)[NSNull null] || contact.lastName.length == 0) { // no last name present in the contact
        self.nameLabel.text = contact.firstName;
    } else if (contact.firstName == (id)[NSNull null] || contact.firstName.length == 0) { // no first name present in contact
        self.nameLabel.text = contact.lastName;
    } else {
        self.nameLabel.text = contact.fullName;
    }
    
    // Set subtitle
    NSString *phoneString = self.contact.firstPhone;
    NSArray *components = [phoneString componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]];
    NSString *decimalString = [components componentsJoinedByString:@""];
    
    NSUInteger length = decimalString.length;
    BOOL hasLeadingOne = length > 0 && [decimalString characterAtIndex:0] == '1';
    
    NSUInteger index = 0;
    NSMutableString *formattedString = [NSMutableString string];
    
    if (hasLeadingOne) {
        [formattedString appendString:@"1 "];
        index += 1;
    }
    
    if (length - index > 3) {
        NSString *areaCode = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"(%@) ",areaCode];
        index += 3;
    }
    
    if (length - index > 3) {
        NSString *prefix = [decimalString substringWithRange:NSMakeRange(index, 3)];
        [formattedString appendFormat:@"%@-",prefix];
        index += 3;
    }
    
    NSString *remainder = [decimalString substringFromIndex:index];
    if (remainder) {
        [formattedString appendString:remainder];
    }
    
    phoneString = formattedString; // finished formatting the phone string from Parse
    self.userSubtitleLabel.text = phoneString;
    
}

#pragma mark - Delegate

- (void)inviteButtonFired:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cell:didTapInviteButton:)]) {
        [self.delegate cell:self didTapInviteButton:self.contact];
    }
}

#pragma mark - Height helper method

+ (CGFloat)heightForContactCell:(CPAContact *)contact width:(CGFloat)width {
    
    // Make a cell
    CPAContactTableViewCell *layoutCell = [[CPAContactTableViewCell alloc] init];
    layoutCell.contact = contact;
    layoutCell.bounds = CGRectMake(0, 0, width, CGRectGetHeight(layoutCell.frame));
    
    [layoutCell setNeedsLayout];
    [layoutCell layoutIfNeeded];
    
    return CGRectGetMaxY(layoutCell.mainView.frame);
}

@end
