//
//  PFAssetPickerViewController.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFAssetPickerViewController.h"
#import "PFAssetCell.h"
#import "PFItem.h"

@import AssetsLibrary;

@interface PFAssetPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    NSMutableArray *items;
    
    UICollectionView *collectionViewAssets;
    UIRefreshControl *refreshControl;
    
    ALAssetsLibrary *library;
}

@end

@implementation PFAssetPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    [self.view addSubview:toolbar];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
    
    toolbar.items = @[cancel];
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    layout.itemSize = CGSizeMake(80, 80);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    collectionViewAssets = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - toolbar.frame.size.height) collectionViewLayout:layout];
    
    [collectionViewAssets registerClass:[PFAssetCell class] forCellWithReuseIdentifier:@"assetCell"];
    
    collectionViewAssets.dataSource = self;
    collectionViewAssets.delegate = self;
    collectionViewAssets.alwaysBounceVertical = YES;
    collectionViewAssets.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:collectionViewAssets];
    
    refreshControl = [UIRefreshControl new];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [collectionViewAssets addSubview:refreshControl];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self refresh];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)refresh
{
    [self getAssetsCompletion:^{
        [collectionViewAssets reloadData];
        [refreshControl endRefreshing];
        [collectionViewAssets scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items.count-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }];
}

-(void)getAssetsCompletion:(void(^)(void))block
{
    if (!items) items = [NSMutableArray array];
    [items removeAllObjects];
    
    if (!library)
        library = [ALAssetsLibrary new];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group){
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result)
                {
                    PFItem *item = [PFItem new];
                    item.asset = result;
                    [items addObject:item];
                }
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block();
            });
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFAssetCell *cell = [collectionViewAssets dequeueReusableCellWithReuseIdentifier:@"assetCell" forIndexPath:indexPath];
    
    PFItem *item = items[indexPath.row];
    cell.item = item;
    
    return cell;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return items.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PFItem *item = items[indexPath.row];
    item.isSelected = !item.isSelected;
    
    [collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
