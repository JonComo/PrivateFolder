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
    
    UIRefreshControl *refreshControl;
    
    NSArray *savedItems;
    
    BOOL didRefresh;
    
    UIBarButtonItem *import;
}

@end

@implementation PFCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    savedItems = [NSMutableArray array];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    
    import = [[UIBarButtonItem alloc] initWithTitle:@"Import" style:UIBarButtonItemStyleBordered target:self action:@selector(import)];
    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settings)];
    
    UIBarButtonItem *export = [[UIBarButtonItem alloc] initWithTitle:@"Export" style:UIBarButtonItemStyleBordered target:self action:@selector(export)];
    
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStyleBordered target:self action:@selector(delete)];
    
    UIBarButtonItem *spacer0 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    
    toolbar.items = @[import, spacer0, settings, spacer1, delete, spacer2, export];
    
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
    
    collectionViewItems.contentInset = UIEdgeInsetsMake([UIApplication sharedApplication].statusBarFrame.size.height, 0, toolbar.frame.size.height, 0);
    
    [self.view addSubview:collectionViewItems];
    [self.view addSubview:toolbar];
    
    refreshControl = [UIRefreshControl new];
    refreshControl.tintColor = [UIColor blackColor];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [collectionViewItems addSubview:refreshControl];
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

-(void)settings
{
    
}

-(void)export
{
    
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
    if (!refreshControl.isRefreshing) [refreshControl beginRefreshing];
    
    [PFItem itemsCompletion:^(NSMutableArray *items) {
        
        savedItems = [items sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            
            PFItem *item1 = (PFItem *)obj1;
            PFItem *item2 = (PFItem *)obj2;
            
            return [item1.dateSaved compare:item2.dateSaved];
        }];
        
        [refreshControl endRefreshing];
        [collectionViewItems reloadData];
        
        [self showMotionCue];
    }];
}

-(void)import
{
    PFAssetPickerViewController *assetPicker = [PFAssetPickerViewController assetPickerCompletion:^(NSMutableArray *items) {
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
    PFItem *item = savedItems[indexPath.row];
    item.isSelected = !item.isSelected;
    
    [collectionView reloadData];
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