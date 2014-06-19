//
//  PFCollectionViewController.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFCollectionViewController.h"

#import "PFAssetPickerViewController.h"

@interface PFCollectionViewController ()

@end

@implementation PFCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)import:(id)sender
{
    PFAssetPickerViewController *assetPicker = [PFAssetPickerViewController new];
    
    [self presentViewController:assetPicker animated:YES completion:nil];
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