//
//  CPAButtonScrollView.m
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAButtonScrollView.h"
#import "CPAConstants.h"

@interface CPAButtonScrollView ()

@property (nonatomic, assign) CGFloat buttonWidth;
@property (nonatomic, strong) UIImageView *gradientImageView;

@end

@implementation CPAButtonScrollView

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.delegate = self;
        self.buttonWidth = 75.0f;
        
        self.gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
        [self addSubview:self.gradientImageView];

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.gradientImageView.frame = self.bounds;
}

#pragma mark - Overrides

- (void)setButtonTitles:(NSArray *)buttonTitles {
    _buttonTitles = buttonTitles;

    int buttonCounter = 0;
    CGFloat dividerWidth = 1;
    
    for (NSString *buttonString in buttonTitles) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor clearColor]];
        [button.titleLabel setAdjustsFontSizeToFitWidth:YES];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:buttonString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                        NSForegroundColorAttributeName : [UIColor lightGrayColor]}]
                          forState:UIControlStateNormal];
        [button setAttributedTitle:[[NSAttributedString alloc] initWithString:buttonString attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f],
                                                                                                        NSForegroundColorAttributeName : [CPAConstants skyBlueColor]}]
                          forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button setFrame:CGRectMake(CGRectGetMinX(self.bounds) + (self.buttonWidth * buttonCounter) + (dividerWidth * buttonCounter),
                                    CGRectGetMinY(self.bounds),
                                    self.buttonWidth,
                                    CGRectGetHeight(self.bounds))];
        buttonCounter ++;
    }
    [self updateContentSize];
    [self bringSubviewToFront:self.gradientImageView];
}

#pragma mark - Button Actions

- (void)buttonPressed:(UIButton *)button {
    [self deselectAllButtons];
    button.selected = YES;
    [self centerScrollViewOnButton:button];
    if (self.buttonDelegate && [self.buttonDelegate respondsToSelector:@selector(buttonScrollViewButtonStringSelected:onButtonScrollView:)]) {
        [self.buttonDelegate buttonScrollViewButtonStringSelected:[button.titleLabel.attributedText string] onButtonScrollView:self];
    }
}

- (void)deselectAllButtons {
    for (UIView *v in [self subviews]) {
        if ([(NSStringFromClass([v class])) isEqualToString:@"UIButton"]) {
            UIButton *currentButton = (UIButton *)v;
            currentButton.selected = NO;
        }
    }
}

#pragma mark - Helper methods

- (void)centerScrollViewOnButtonWithStringTitle:(NSString *)buttonTitle {
    [self deselectAllButtons];
    for (UIView *view in [self subviews]) {
        if ([(NSStringFromClass([view class])) isEqualToString:@"UIButton"]) {
            UIButton *currentButton = (UIButton *)view;
            if ([currentButton.titleLabel.text isEqualToString:buttonTitle]) {
                [self centerScrollViewOnButton:currentButton];
                currentButton.selected = YES;
            }
        }
    }
}

- (void)centerScrollViewOnButton:(UIButton *)button {
    [self scrollRectToVisible:button.frame animated:YES];
}

- (void)updateContentSize {

    float width = 0;
    for (UIView *v in [self subviews]) {
        if (![(NSStringFromClass([v class])) isEqualToString:@"UIImageView"]) { // HAVE TO EXCLUDE UIIMAGEVIEW'S HERE BECAUSE THERE IS A RANDOM UIIMAGEVIEW PRESENT IN UISCROLLVIEW
            float fw = v.frame.origin.x + v.frame.size.width;
            width = MAX(fw, width);
        }
    }
    [self setContentSize:CGSizeMake(width, CGRectGetHeight(self.bounds))];
    // Set the scrollview content inset so that we can scroll buttons all across the scroll view
    [self setContentInset:UIEdgeInsetsMake(0,
                                           CGRectGetWidth(self.bounds) / 2 - (self.buttonWidth / 2),
                                           0,
                                           CGRectGetWidth(self.bounds) / 2 - (self.buttonWidth / 2))];

}

@end
