//
//  CPACache.m
//  Referrall
//
//  Created by Collin Adler on 8/27/15.
//  Copyright (c) 2015 Cabarary, Inc. All rights reserved.
//

#import "CPACache.h"

@interface CPACache ()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation CPACache

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - CABCache

- (void)clear {
    [self.cache removeAllObjects];
}

@end
