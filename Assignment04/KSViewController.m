//
//  KSViewController.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "KSViewController.h"
#import "KSImage.h"
#import "KSPixel.h"

@interface KSViewController ()

@end

@implementation KSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *imagePath       = @"/Users/khaledalyousefi/Dropbox/CSC-505/rose.png";
    NSString *outputDirPath   = @"/Users/khaledalyousefi/Downloads/images" ;
    
    
     //#####################################  PART I-A  #####################################
     // Read the image into RGB space
     KSImage *image1 = [[KSImage alloc] initWithImageFile:imagePath];
     // Fade an image into Gray within RGB color space by creating a sequence of images
     [image1 fadeGrayToPath:outputDirPath NumberOfImages:10];
     
     //#####################################  PART I-B  #####################################
     // Read the image into RGB space
     KSImage *image2 = [[KSImage alloc] initWithImageFile:imagePath];
     // Convert the image to YPbPr color space from RGB color space
     [image2 convertToColorSpace:YPbPr];
     // Fade an image into Gray within YPbPr color space by creating a sequence of images
     [image2 fadeGrayToPath:outputDirPath NumberOfImages:10];
     // Convert the image back to RGB color space
     [image2 convertToColorSpace:RGB];
     
     //#####################################  PART II  ######################################
     // Read the image into RGB space
     KSImage *image3 = [[KSImage alloc] initWithImageFile:imagePath];
     // Convert an 8-bit gray scale image to a 1-bit dithered binary image using Floyd-Steinberg algorithm
     [image3 ditherBlackWhiteToPath:outputDirPath];
     
     //#####################################  E X T R A  ####################################
     KSImage *image4 = [[KSImage alloc] initWithImageFile:imagePath];
     
     // Redraw an image with 6-color mode using Floyd-Steinberg algorithm
     [image4 ditherSixColorsToPath:outputDirPath];
     
     // Resize an image by doubling its size
     [image4 resizeImage:2 ToPath:outputDirPath];
     
    
     // Fade between two different images
     KSImage *image11 = [[KSImage alloc] initWithImageFile:@"/Users/khaledalyousefi/Dropbox/CSC-505/rose1.png"];
     KSImage *image12 = [[KSImage alloc] initWithImageFile:@"/Users/khaledalyousefi/Dropbox/CSC-505/rose2.png"];     
     [image12 fadeToImage:image11 ToPath:outputDirPath NumberOfImages:10];
    
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
