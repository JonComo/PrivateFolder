//
//  PFAssetCell.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFAssetCell.h"

#import "PFItem.h"

@import AssetsLibrary;

@implementation PFAssetCell
{
    UIImageView *imageViewThumb;
    UIImageView *imageViewSelected;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageViewThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:imageViewThumb];
        
        imageViewSelected = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        imageViewSelected.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:imageViewSelected];
    }
    return self;
}

-(void)setItem:(PFItem *)item
{
    _item = item;
    
    //show a thumbnail
    imageViewThumb.image = [UIImage imageWithCGImage:item.asset.thumbnail];
    
    if (item.isSelected)
    {
        imageViewSelected.image = [UIImage imageNamed:@"selected"];
    }else{
        imageViewSelected.image = nil;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
