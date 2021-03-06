//
//  PFCollectionViewController.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFCollectionViewController.h"

#import "PFAssetPickerViewController.h"

#import "PFAssetCell.h"

@interface PFCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    UICollectionView *collectionViewItems;
    
    NSArray *savedItems;
    
    BOOL didRefresh;
    
    UIToolbar *toolbar;
    
    UIBarButtonItem *import;
    UIBarButtonItem *export;
    UIBarButtonItem *delete;
    //UIBarButtonItem *settings;
    
    UIBarButtonItem *spacer0;
    UIBarButtonItem *spacer1;
    UIBarButtonItem *spacer2;
    
    UIBarButtonItem *selectButton;
    
    UIView *fade;
    
    BOOL statusBarHidden;
    
    int presentedIndex;
    
    UIImageView *imageView; //presented image view
    
    BOOL isSelecting;
}

@end

@implementation PFCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Private Folder";
    
    fade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    fade.backgroundColor = [UIColor blackColor];
    
    savedItems = [NSMutableArray array];
    
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    
    import = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStyleBordered target:self action:@selector(import)];
    
    //settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
    
    export = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action:@selector(export)];
    
    delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(delete)];
    
    spacer0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    toolbar.items = @[import];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    collectionViewItems = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) collectionViewLayout:layout];
    
    [collectionViewItems registerClass:[PFAssetCell class] forCellWithReuseIdentifier:@"assetCell"];
    
    collectionViewItems.dataSource = self;
    collectionViewItems.delegate = self;
    collectionViewItems.alwaysBounceVertical = YES;
    collectionViewItems.backgroundColor = [UIColor whiteColor];
    
    collectionViewItems.contentInset = UIEdgeInsetsMake(self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height, 0, toolbar.frame.size.height, 0);
    
    [self.view addSubview:collectionViewItems];
    [self.view addSubview:toolbar];
    
    selectButton = [[UIBarButtonItem alloc] initWithTitle:@"Select" style:UIBarButtonItemStylePlain target:self action:@selector(toggleSelect)];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!didRefresh)
    {
        didRefresh = YES;
        [self refresh];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return statusBarHidden;
}

-(void)toggleSelect
{
    isSelecting = !isSelecting;
    
    NSDictionary *attributes;
    
    if (isSelecting){
        attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17]};
        [self.navigationItem.rightBarButtonItem setTitle:@"Cancel"];
        
        [toolbar setItems:@[delete, spacer2, export] animated:YES];
        
    }else{
        attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:17]};
        [self.navigationItem.rightBarButtonItem setTitle:@"Select"];
        
        for (PFItem *item in savedItems)
            item.isSelected = NO;
        [collectionViewItems reloadData];
        
        [toolbar setItems:@[import] animated:YES];
    }
    
    [self.navigationItem.rightBarButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

-(void)settings
{
    
}

-(void)export
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Exporting to Photo Library";
    
    __block int numToExport = 0;
    
    for (PFItem *item in savedItems){
        if (item.isSelected){
            numToExport ++;
            
            NSData *data = [NSData dataWithContentsOfURL:item.dataURL];
            if (data){
                [[PFAssetPickerViewController sharedLibrary] writeImageDataToSavedPhotosAlbum:data metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                    numToExport --;
                    
                    if (numToExport == 0){
                        hud.labelText = @"Success";
                        hud.mode = MBProgressHUDModeText;
                        [hud hide:YES afterDelay:1];
                    }
                }];
            }
        }
    }
}

-(void)delete
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Deleting";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        for (PFItem *item in savedItems){
            if (item.isSelected){
                [item remove];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [self refresh];
        });
    });
}

-(void)refresh
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Loading";
    
    [PFItem itemsCompletion:^(NSMutableArray *items) {
        
        [hud hide:YES];
        
        savedItems = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            PFItem *item1 = (PFItem *)obj1;
            PFItem *item2 = (PFItem *)obj2;
            
            return [item1.dateSaved compare:item2.dateSaved];
        }];
        
        [collectionViewItems reloadData];
        
        if (isSelecting && savedItems.count == 0)
            [self toggleSelect]; //go back to import view
        if (savedItems.count == 0)
        {
            self.navigationItem.rightBarButtonItem = nil;
        }else{
            self.navigationItem.rightBarButtonItem = selectButton;
        }
        
        [self showMotionCue];
    }];
}

-(void)import
{
    PFAssetPickerViewController *assetPicker = [PFAssetPickerViewController assetPickerCompletion:^{
        [self refresh];
    }];
    
    [self presentViewController:assetPicker animated:YES completion:nil];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFAssetCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"assetCell" forIndexPath:indexPath];
    
    PFItem *item = savedItems[indexPath.row];
    cell.item = item;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return savedItems.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSelecting){
        PFItem *item = savedItems[indexPath.row];
        item.isSelected = !item.isSelected;
        
        [collectionView reloadData];
    }else{
        presentedIndex = indexPath.row;
        [self showImageView];
    }
}

-(void)swipeRight
{
    presentedIndex -= 1;
    
    if (presentedIndex < 0){
        presentedIndex = 0;
        
        [UIView animateWithDuration:0.1 animations:^{
            imageView.layer.transform = CATransform3DMakeTranslation(30, 0, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.12 animations:^{
                imageView.layer.transform = CATransform3DIdentity;
            }];
        }];
        
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.layer.transform = CATransform3DMakeTranslation(100, 0, 0);
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        imageView.layer.transform = CATransform3DMakeTranslation(-100, 0, 0);
        [self showImageView];
        
        [UIView animateWithDuration:0.2 animations:^{
            imageView.layer.transform = CATransform3DIdentity;
            imageView.alpha = 1;
        }];
    }];
}

-(void)swipeLeft
{
    presentedIndex += 1;
    
    if (presentedIndex > savedItems.count-1){
        presentedIndex = savedItems.count-1;
        
        
        [UIView animateWithDuration:0.1 animations:^{
            imageView.layer.transform = CATransform3DMakeTranslation(-30, 0, 0);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.12 animations:^{
                imageView.layer.transform = CATransform3DIdentity;
            }];
        }];
        
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.layer.transform = CATransform3DMakeTranslation(-100, 0, 0);
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        imageView.layer.transform = CATransform3DMakeTranslation(100, 0, 0);
        [self showImageView];
        
        [UIView animateWithDuration:0.2 animations:^{
            imageView.layer.transform = CATransform3DIdentity;
            imageView.alpha = 1;
        }];
    }];
}

-(void)showImageView
{
    if (presentedIndex < 0){
        presentedIndex = 0;
        return;
    }
    
    if (presentedIndex > savedItems.count - 1){
        presentedIndex = savedItems.count - 1;
        return;
    }
    
    if (!imageView){
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [imageView setUserInteractionEnabled:YES];
        
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideImageView:)]];
        
        UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        [imageView addGestureRecognizer:swipeRight];
        
        UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [imageView addGestureRecognizer:swipeLeft];
    }
    
    PFItem *item = savedItems[presentedIndex];
    UIImage *image = [UIImage imageWithContentsOfFile:[item.largeThumbnailURL path]];
    imageView.image = image;
    
    if (!imageView.superview)
    {
        imageView.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9);
        imageView.alpha = 0;
        
        fade.alpha = 0;
        
        [self.view addSubview:fade];
        [self.view addSubview:imageView];
        
        [UIView animateWithDuration:0.2 animations:^{
            imageView.alpha = 1;
            fade.alpha = 1;
            imageView.layer.transform = CATransform3DIdentity;
        }];
    }
    
    statusBarHidden = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)hideImageView:(UITapGestureRecognizer *)tap
{
    [UIView animateWithDuration:0.2 animations:^{
        fade.alpha = 0;
        
        tap.view.alpha = 0;
        tap.view.layer.transform = CATransform3DMakeScale(0.9, 0.9, 0.9);
    } completion:^(BOOL finished) {
        [tap.view removeFromSuperview];
        [fade removeFromSuperview];
    }];
    
    statusBarHidden = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)showMotionCue
{
    if (savedItems.count == 0){
        //show import
        [self wiggleView:[import valueForKey:@"view"]];
    }
}

-(void)wiggleView:(UIView *)view
{
    [UIView animateWithDuration:0.1 animations:^{
        view.layer.transform = CATransform3DMakeRotation(-0.2, 0, 0, 1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            view.layer.transform = CATransform3DMakeRotation(0.2, 0, 0, 1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                view.layer.transform = CATransform3DMakeRotation(-0.1, 0, 0, 1);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    view.layer.transform = CATransform3DMakeRotation(0, 0, 0, 1);
                } completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }];
}

@end