//
//  CPAInsetTextField.m
//  Referrall
//
//  Created by Collin Adler on 8/24/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAInsetTextField.h"

@implementation CPAInsetTextField

- (id)init {
    self = [super init];
    if (self) {
        // Perform anything else additional
    }
    return self;
}


/* Override text rects so that there is a little padding from the bounds of the text field */

// placeholder position
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 5 );
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 5 );
}

@end
