//
//  PSRClassWichPerformsAsyncOperations.m
//  PhotosViewer
//
//  Created by n.shubenkov on 31/08/14.
//  Copyright (c) 2014 n.shubenkov. All rights reserved.
//

#import "PSRClassWichPerformsAsyncOperations.h"


@interface PSRClassWichPerformsSomethingWithComplitionBlock()

@end

@implementation PSRClassWichPerformsSomethingWithComplitionBlock

- (void)performSomeOperationWithComplition:(PSRComplitionBlock)complition
{
    //make copy of block, wich was passed to you
    PSRComplitionBlock copiedComplition = [complition  copy];
    
    //do some long task.
    //make performing this task in background
    NSString *result = [self calculateLongTask];
    
    if (copiedComplition){
        copiedComplition(result);
    }
    
}

- (NSString *)calculateLongTask
{
    //some long task
    [NSThread sleepForTimeInterval:5];
    
    return @"Task finished";
}

@end
