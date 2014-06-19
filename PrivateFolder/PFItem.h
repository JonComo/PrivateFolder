//
//  PFItem.h
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ALAsset;

@interface PFItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString *prefix;

@property BOOL isSelected;
@property (nonatomic, strong) ALAsset *asset;

//for saved files:
@property (nonatomic, strong) NSURL *archiveURL;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, strong) NSURL *dataURL;
@property (nonatomic, strong) NSDate *dateSaved;

-(void)saveCompletion:(void(^)(void))block;
-(void)remove;
+(void)itemsCompletion:(void(^)(NSMutableArray *items))block;

@end