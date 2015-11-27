//
//  UIImage+CABImageUtilities.h
//  Cabaray
//
//  Created by Collin Adler on 12/23/14.
//  Copyright (c) 2014 Cabarary, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (CABImageUtilities)

- (UIImage *) imageWithFixedOrientation;
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size;
- (UIImage *) imageCroppedToRect:(CGRect)cropRect;
- (UIImage *) imageByScalingToSize:(CGSize)size andCroppingWithRect:(CGRect)rect;

@end
