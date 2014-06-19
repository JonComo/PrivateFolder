//
//  PFItem.h
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;

@interface PFItem : NSObject

@property BOOL isSelected;
@property (nonatomic, strong) ALAsset *asset;

@end