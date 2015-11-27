//
//  CPAParseUtility.h
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CPAParseUtility : NSObject

+ (void)followUserEventually:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;

+ (void)unfollowUserEventually:(PFUser *)user;

// General helper methods
+ (BOOL)userHasProfilePictures:(PFUser *)user;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
