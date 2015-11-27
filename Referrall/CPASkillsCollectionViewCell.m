//
//  CPASkillsCollectionViewCell.m
//  Referrall
//
//  Created by Collin Adler on 8/26/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPASkillsCollectionViewCell.h"
#import "CPAConstants.h"

@interface CPASkillsCollectionViewCell ()

@property (nonatomic, strong) UILabel *skillLabel;

@end

@implementation CPASkillsCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.skillLabel = [[UILabel alloc] init];
        self.skillLabel.backgroundColor = [CPAConstants skyBlueColor];
        self.skillLabel.textAlignment = NSTextAlignmentCenter;
        self.skillLabel.adjustsFontSizeToFitWidth = YES;
        self.skillLabel.numberOfLines = 2;
        self.skillLabel.layer.cornerRadius = 8;
        self.skillLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:self.skillLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.skillLabel.frame = CGRectMake(0,
                                       0,
                                       CGRectGetWidth(self.bounds),
                                       CGRectGetHeight(self.bounds));
}

#pragma mark - Overrides

- (void)setSkillString:(NSString *)skillString {
    _skillString = skillString;
    [self.skillLabel setAttributedText:[[NSAttributedString alloc] initWithString:_skillString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f],
                                                                                                            NSForegroundColorAttributeName : [UIColor whiteColor]}]];
}

- (void)setState:(CPASkillsCollectionViewCellState)state {
    _state = state;
    switch (self.state) {
        case CPASkillsCollectionViewCellStateNotSelected: {
            self.skillLabel.backgroundColor = [CPAConstants skyBlueColor];
            [self.skillLabel setAttributedText:[[NSAttributedString alloc] initWithString:_skillString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0f],
                                                                                                                    NSForegroundColorAttributeName : [UIColor whiteColor]}]];
        } break;
        case CPASkillsCollectionViewCellStateSelected: {
            self.skillLabel.backgroundColor = [UIColor whiteColor];
            [self.skillLabel setAttributedText:[[NSAttributedString alloc] initWithString:_skillString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:11.0f],
                                                                                                                    NSForegroundColorAttributeName : [CPAConstants skyBlueColor]}]];
        } break;
    }
}

#pragma mark - Animation

- (void)performAnimation {

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.xy"];
    pulseAnimation.fromValue = @0.85;
    pulseAnimation.toValue = @1;
    pulseAnimation.duration = 0.2f;
    
    [self.layer addAnimation:pulseAnimation forKey:@"pulse"];
    
}

@end
