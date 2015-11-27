//
//  CPACache.h
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CPACache : NSObject

+ (id)sharedCache;

- (void)clear;

@end
