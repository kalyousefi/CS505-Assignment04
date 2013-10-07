//
//  KSImage.h
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPixel.h"

typedef NS_ENUM(NSUInteger, ColorSpace) {
    RGB,
    YPbPr
};

@interface KSImage : NSObject

@property int width;
@property int height;
@property (nonatomic) NSMutableArray *pixelsArray;
@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *filenameWithoutExtension;
@property ColorSpace colorSpace;

-(id)   initWithImageFile:(NSString*)filePath;
-(void) writeImageArray:(NSArray*) pixelArray ToPath:(NSString*)dirPath;
-(void) fadeGrayToPath:(NSString*) dirPath NumberOfImages:(int)numberOfImages;
-(void) ditherBlackWhiteToPath:(NSString*) dirPath;
-(void) ditherSixColorsToPath:(NSString*) dirPath;
-(void) convertToColorSpace:(ColorSpace)colorSpace;
-(void) resizeImage:(int)stepSize ToPath:(NSString*)dirPath;

-(void) morphToImage:(KSImage*) image2 ToPath:(NSString*) dirPath NumberOfImages:(int)numberOfImages;

@end
