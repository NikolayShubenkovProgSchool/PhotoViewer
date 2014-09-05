//
//  OSTAImageContentViewController.m
//  FlickrPhotosViewer
//
//  Created by Admin on 04.09.14.
//  Copyright (c) 2014 Ostasoft. All rights reserved.
//

#import "OSTAImageContentViewController.h"

@interface OSTAImageContentViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation OSTAImageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.image){
        self.imageView.image = self.image;
    }
    
    if (self.text){
        self.textView.text = self.text;
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //animation
    [UIView animateWithDuration:1.5 animations:^{
        self.imageView.alpha = 1;
        self.textView.alpha = 1;
    }];
}

- (IBAction)backToSearchButtonTouchUoInside:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        //nothing to do
    }];
}

@end
