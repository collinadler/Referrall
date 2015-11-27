//
//  CPAJob.h
//  Referrall
//
//  Created by Collin Adler on 9/24/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface CPAJob : NSObject

@property (nonatomic, strong, readonly) PFObject *object;

@property (nonatomic, strong) NSString *objectId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *company;
@property (nonatomic, strong) NSString *industry;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *jobDescription;
@property (nonatomic, strong) NSArray *skills;
@property (nonatomic, strong) PFUser *user;

// Initializers
- (instancetype)initWithObject:(PFObject *)jobObject;

@end
