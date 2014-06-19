//
//  PFAssetPickerViewController.h
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PFItem.h"

typedef void (^AssetPickerCompletion)(void);

@interface PFAssetPickerViewController : UIViewController

@property (nonatomic, copy) AssetPickerCompletion completion;

+(ALAssetsLibrary *)sharedLibrary;
+(PFAssetPickerViewController *)assetPickerCompletion:(AssetPickerCompletion)completion;

@end