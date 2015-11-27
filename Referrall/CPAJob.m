//
//  CPAJob.m
//  Referrall
//
//  Created by Collin Adler on 9/24/15.
//  Copyright © 2015 Cabarary, Inc. All rights reserved.
//

#import "CPAJob.h"

@interface CPAJob ()

// Privately declared
@property (nonatomic, strong) PFObject *object;

@end

@implementation CPAJob

- (instancetype)initWithObject:(PFObject *)jobObject {
    self = [super init];
    if (self) {
        [jobObject fetchIfNeeded];
        
        self.object = jobObject;
        self.objectId = jobObject.objectId;
        
        self.title = jobObject[@"title"];
        self.company = jobObject[@"company"];
        self.industry = jobObject[@"industry"];
        self.locationString = jobObject[@"locationString"];
        self.type = jobObject[@"type"];
        self.jobDescription = jobObject[@"description"];
        self.skills = jobObject[@"skills"];
        
        self.user = jobObject[@"user"];

    }
    return self;
}

@end
