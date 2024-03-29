//
//  CPAOnboardingContentViewController.h
//  Referrall
//
//  Created by Collin Adler on 8/25/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPAOnboardingViewController;

@interface CPAOnboardingContentViewController : UIViewController {
    NSString *_titleText;
    NSString *_body;
    UIImage *_image;
    NSString *_buttonText;
    
    UIImageView *_imageView;
    UILabel *_mainTextLabel;
    UILabel *_subTextLabel;
    UIButton *_actionButton;
}

@property (nonatomic) CPAOnboardingViewController *delegate;

@property (nonatomic) BOOL movesToNextViewController;

@property (nonatomic) CGFloat iconHeight;
@property (nonatomic) CGFloat iconWidth;

@property (nonatomic, strong) UIColor *titleTextColor;
@property (nonatomic, strong) UIColor *bodyTextColor;
@property (nonatomic, strong) UIColor *buttonTextColor;

@property (nonatomic, strong) NSString *titleFontName;
@property (nonatomic) CGFloat titleFontSize;

@property (nonatomic, strong) NSString *bodyFontName;
@property (nonatomic) CGFloat bodyFontSize;

@property (nonatomic, strong) NSString *buttonFontName;
@property (nonatomic) CGFloat buttonFontSize;

@property (nonatomic) CGFloat topPadding;
@property (nonatomic) CGFloat underIconPadding;
@property (nonatomic) CGFloat underTitlePadding;
@property (nonatomic) CGFloat bottomPadding;
@property (nonatomic) CGFloat underPageControlPadding;

@property (nonatomic, copy) dispatch_block_t buttonActionHandler;

@property (nonatomic, copy) dispatch_block_t viewWillAppearBlock;
@property (nonatomic, copy) dispatch_block_t viewDidAppearBlock;
@property (nonatomic, copy) dispatch_block_t viewWillDisappearBlock;
@property (nonatomic, copy) dispatch_block_t viewDidDisappearBlock;

+ (instancetype)contentWithTitle:(NSString *)title body:(NSString *)body image:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action;
- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body image:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action;

- (void)updateAlphas:(CGFloat)newAlpha;

@end