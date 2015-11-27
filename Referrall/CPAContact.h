//
//  CPAContact.h
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CPAContact : NSObject

@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *fullName;
@property (nonatomic, strong) NSString *firstEmail;
@property (nonatomic, strong) NSString *secondEmail;
@property (nonatomic, strong) NSString *firstPhone;
@property (nonatomic, strong) NSString *secondPhone;

@end
