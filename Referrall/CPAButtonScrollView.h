//
//  CPAButtonScrollView.h
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CPAButtonScrollView;

@protocol CPAButtonScrollViewDelegate <NSObject>

// Pop up view delegate methods
- (void)buttonScrollViewButtonStringSelected:(NSString *)buttonString onButtonScrollView:(CPAButtonScrollView *)buttonScrollView;

@end

@interface CPAButtonScrollView : UIScrollView

@property (nonatomic, strong) NSArray *buttonTitles;
@property (nonatomic, weak) id <CPAButtonScrollViewDelegate> buttonDelegate;

- (void)centerScrollViewOnButtonWithStringTitle:(NSString *)buttonTitle;

@end
