//
//  OSTAViewController.m
//  FlickrPhotosViewer
//
//  Created by Admin on 02.09.14.
//  Copyright (c) 2014 Ostasoft. All rights reserved.
//

#import "OSTAViewController.h"
#import "OSTACollectionViewCell.h"
#import "OSTAImageContentViewController.h"
#import "PSRFlickrSearchOptions.h"
#import "PSRFlickrAPI.h"
#import "PSRFlickrPhoto.h"

#define showFullImageContentSegueName @"showFullImageContent"

@interface OSTAViewController ()
@property (nonatomic, strong) PSRFlickrSearchOptions *searchOptions;
@property (nonatomic, strong) NSMutableArray *loadedPhotos;
@property (nonatomic, strong) NSMutableArray *flickrPhotos;
@end

@implementation OSTAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

/**
 init searchOptions
 */
- (void)updateSearchOptionsWithTag:(NSString *)tag
{
    if (tag && ![tag isEqual:@""])
    {
        PSRFlickrSearchOptions *options = [[PSRFlickrSearchOptions alloc]initWithTags:@[tag]];
        
        options.itemsLimit = 8;
        //options.page = 4;
        //options.coordinate = CLLocationCoordinate2DMake(55.756151, 37.61727);
        //options.radiousKilometers = 50;
        options.extra = @[@"original_format",
                          @"tags",
                          @"description",
                          @"geo",
                          @"date_upload",
                          @"owner_name"];
        
        self.searchOptions = options;
    }
}

/**
 search started
 */
- (IBAction)searchStarted:(id)sender
{
    if (self.searchTextField.text)
    {
        //clear collections for next search
        [self.loadedPhotos removeAllObjects];
        [self.flickrPhotos removeAllObjects];
        [self.collectionView reloadData];

        [self searchTextFieldReturn:self.searchTextField];
        [self updateSearchOptionsWithTag:self.searchTextField.text];
        [self searchAndDownloadPhotos];
    }
}

-(void)searchAndDownloadPhotos
{
    dispatch_queue_t searchQueue = dispatch_queue_create("search queue", 0);
    dispatch_async(searchQueue, ^{
        self.flickrPhotos = [[[PSRFlickrAPI alloc]init] requestPhotosWithOptions:self.searchOptions];
        NSLog(@"search completed");
        
        for (PSRFlickrPhoto *flickrPhoto in self.flickrPhotos)
        {
            [self downloadPhotoWithFlickrPhoto:flickrPhoto];
        }
        
    });
}

- (void)downloadPhotoWithFlickrPhoto:(PSRFlickrPhoto *)flickrPhoto
{
    dispatch_queue_t downloadQueue = dispatch_queue_create("download queue", 0);
    dispatch_async(downloadQueue, ^{
        if (!flickrPhoto)
            return;
        
        NSData *photoData = [NSData dataWithContentsOfURL:[flickrPhoto highQualityURL]];
        if (!photoData)
            return;
        
        NSLog(@"image downloaded");
        
        UIImage *photo = [UIImage imageWithData:photoData];
        if (!photo)
            return;
        
        if (!self.loadedPhotos)
            self.loadedPhotos = [NSMutableArray new];
            
        [self.loadedPhotos addObject:photo];
        
        //if all download threads completed
        if ([self.loadedPhotos count] ==[self.flickrPhotos count])
        {
            dispatch_queue_t mainQueue = dispatch_get_main_queue();
            dispatch_async(mainQueue, ^{
                //refresh collectionView
                [self.collectionView reloadData];
            });
        }
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (!sender || ![sender isKindOfClass:[NSIndexPath class]])
        return;
    
    NSIndexPath *indexPath = (NSIndexPath *)sender;
    
    UIImage *photo = self.loadedPhotos[indexPath.row];
    if (!photo)
        return;
    
    PSRFlickrPhoto *flickrPhoto = (PSRFlickrPhoto *)self.flickrPhotos[indexPath.row];
    if (!flickrPhoto)
        return;
    
    NSString *flickrPhotoDescription = [flickrPhoto.info objectForKey:@"title"];
    if (!flickrPhotoDescription)
        return;
    
    if (![segue.destinationViewController isKindOfClass:[OSTAImageContentViewController class]])
        return;
    
    OSTAImageContentViewController *imageContentViewController = segue.destinationViewController;
    imageContentViewController.image = photo;
    imageContentViewController.text = flickrPhotoDescription;
}

#pragma mark - UICollectionView delegate methods -

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.loadedPhotos)
        return [self.loadedPhotos count];
    
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    OSTACollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    if (!cell)
        return cell;
    
    if (![cell isKindOfClass:[OSTACollectionViewCell class]])
        return cell;
    
    cell.imageView.image = self.loadedPhotos[indexPath.row];
    
    PSRFlickrPhoto *flickrPhoto = (PSRFlickrPhoto *)self.flickrPhotos[indexPath.row];
    if (!flickrPhoto)
        return cell;
    
    NSString *flickrPhotoDescription = [flickrPhoto.info objectForKey:@"title"];
    if (!flickrPhotoDescription)
        return cell;
    
    cell.label.text = flickrPhotoDescription;
        
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:showFullImageContentSegueName sender:indexPath];
}

#pragma mark - hiding the keyboard -

/**
 hide keyboard if return
 */
- (IBAction)searchTextFieldReturn:(id)sender
{
    if ([self.searchTextField isFirstResponder])
        [self.searchTextField resignFirstResponder];
}

/**
 when user taps the background
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.searchTextField isFirstResponder] && [touch view] != self.searchTextField) {
        [self.searchTextField resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}
@end
