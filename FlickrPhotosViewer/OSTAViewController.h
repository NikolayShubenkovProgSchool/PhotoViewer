//
//  OSTAViewController.h
//  FlickrPhotosViewer
//
//  Created by Admin on 02.09.14.
//  Copyright (c) 2014 Ostasoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSTAViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end
