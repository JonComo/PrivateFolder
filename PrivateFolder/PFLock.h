//
//  PFLock.h
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFLock : NSObject

@property (nonatomic, strong) NSString *passcode;
@property BOOL isLocked;

+(PFLock *)shared;

@end