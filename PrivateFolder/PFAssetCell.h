//
//  PFAssetCell.h
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PFItem;

@interface PFAssetCell : UICollectionViewCell

@property (nonatomic, weak) PFItem *item;

@end