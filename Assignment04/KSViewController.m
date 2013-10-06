//
//  KSViewController.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "KSViewController.h"

@interface KSViewController ()

@end

@implementation KSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *imageFile       = @"/Users/khaledalyousefi/Dropbox/CSC-505/Homeworks/rose.png";
    NSString *outputDirectory = @"/Users/khaledalyousefi/Documents/Homeworks" ;
    KSImage *image = [[KSImage alloc] initWithImageFile:imageFile];
    
    // PART I  : create sequence of png files that fade from color image into gray image discarding Pb and Pr components
    //[image fadeImageToGrayToDirectoryPath:outputDirectory ForImageType:YChannel NumberOfImages:10];
    
    // PART II : create sequence of png files that fade from color image into gray image for YPbPr space
    [image fadeImageToGrayToDirectoryPath:outputDirectory ForImageType:RGB NumberOfImages:10];
    
    
    //[image writeYPbPrImageFile:imageFile ToDirectoryPath:outputDirectory];
    
    //[image fadeImageToGrayToDirectoryPath:outputDirectory ForImageType:YPbPrChannel NumberOfImages:10];

    //[image writeImageToDirectoryPath:outputDirectory ForImageType:YPbPrChannel];
    
    // PART III: convert an 8-bit gray scale image to a 1-bit dithered binary image using the Floyd-Steinberg algorithm
    //[image writeFloydSteinbergDitheringToDirectoryPath:outputDirectory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
