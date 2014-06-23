//
//  PFItem.m
//  PrivateFolder
//
//  Created by Jon Como on 6/18/14.
//  Copyright (c) 2014 Jon Como. All rights reserved.
//

#import "PFItem.h"

#import "PFAssetPickerViewController.h"

#define DOCUMENTS [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]

static NSDateFormatter *formatter;

@implementation PFItem

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        //init
        _thumbnail = [aDecoder decodeObjectForKey:@"thumbnail"];
        _dataURL = [aDecoder decodeObjectForKey:@"dataURL"];
        _archiveURL = [aDecoder decodeObjectForKey:@"archiveURL"];
        _dateSaved = [aDecoder decodeObjectForKey:@"dateSaved"];
        _largeThumbnailURL = [aDecoder decodeObjectForKey:@"largeThumb"];
    }
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.thumbnail forKey:@"thumbnail"];
    [aCoder encodeObject:self.dataURL forKey:@"dataURL"];
    [aCoder encodeObject:self.archiveURL forKey:@"archiveURL"];
    [aCoder encodeObject:[NSDate date] forKey:@"dateSaved"];
    [aCoder encodeObject:self.largeThumbnailURL forKey:@"largeThumb"];
}

-(id)init
{
    if (self = [super init]) {
        //init
        
    }
    
    return self;
}

-(NSURL *)uniqueURLWithPrefix:(NSString *)prefix
{
    NSString *documents = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask][0];
    
    int count = 0;
    NSURL *URL;
    
    do {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@_%i", documents, prefix, count]];
        count ++;
    } while ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]]);
    
    return URL;
}

-(UIImage *)thumbnail
{
    if (self.asset && [PFAssetPickerViewController sharedLibrary]) return [UIImage imageWithCGImage:self.asset.thumbnail];
    return _thumbnail;
}

-(void)saveCompletion:(void (^)(void))block
{
    self.archiveURL = [self uniqueURLWithPrefix:@"information"];
    self.dataURL = [self uniqueURLWithPrefix:@"data"];
    self.largeThumbnailURL = [self uniqueURLWithPrefix:@"largeThumb"];
    
    [[PFAssetPickerViewController sharedLibrary] assetForURL:[self.asset valueForProperty:ALAssetPropertyAssetURL] resultBlock:^(ALAsset *asset) {
        // get data
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        UIImage *image = [UIImage imageWithCGImage:[representation fullResolutionImage] scale:[representation scale] orientation:(int)[representation orientation]];
        
        NSData *data = UIImageJPEGRepresentation(image, 1);
        [data writeToURL:self.dataURL atomically:YES];
        
        UIImage *largeThumb = [UIImage imageWithCGImage:[representation fullScreenImage] scale:[representation scale] orientation:(int)[representation orientation]];
        
        NSData *dataLargeThumb = UIImagePNGRepresentation(largeThumb);
        [dataLargeThumb writeToURL:self.largeThumbnailURL atomically:YES];
        
        [NSKeyedArchiver archiveRootObject:self toFile:[self.archiveURL path]];
        
        if (block) block();
        
    } failureBlock:^(NSError *error) {
        if (block) block();
    }];
}

-(void)remove
{
    [[NSFileManager defaultManager] removeItemAtURL:self.archiveURL error:nil];
    [[NSFileManager defaultManager] removeItemAtURL:self.dataURL error:nil];
}

+(void)itemsCompletion:(void (^)(NSMutableArray *))block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSMutableArray *items = [NSMutableArray array];
        
        NSArray *filenames = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:DOCUMENTS error:nil];
        
        for (NSString *filename in filenames)
        {
            NSArray *components = [filename componentsSeparatedByString:@"_"];
            
            if (components.count < 2) continue;
            
            if ([components[0] isEqualToString:@"information"])
            {
                NSURL *fileURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", DOCUMENTS, filename]];
                NSData *data = [NSData dataWithContentsOfURL:fileURL];
                PFItem *item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                [items addObject:item];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(items);
        });
    });
}

@end
