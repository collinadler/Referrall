//
//  CPASkillsCollectionViewCell.h
//  Referrall
//
//  Created by Collin Adler on 8/26/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CPASkillsCollectionViewCellState) {
    CPASkillsCollectionViewCellStateNotSelected,
    CPASkillsCollectionViewCellStateSelected
};

@interface CPASkillsCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) CPASkillsCollectionViewCellState state;
@property (nonatomic, strong) NSString *skillString;

- (void)performAnimation;

@end
