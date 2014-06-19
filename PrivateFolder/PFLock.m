//
//  PFLock.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFLock.h"

@implementation PFLock

-(NSString *)passcode
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:PASSCODE];
}

+(PFLock *)shared
{
    static PFLock *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[PFLock alloc] init];
    });
    
    return shared;
}

-(id)init
{
    if (self = [super init]) {
        //init
        _isLocked = YES;
    }
    
    return self;
}

@end