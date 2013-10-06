//
//  KSImage.h
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSPixel.h"

typedef NS_ENUM(NSUInteger, ImageType) {
    RGB,
    YChannel,
    YPbPrChannel
};

@interface KSImage : NSObject

@property int width;
@property int height;
@property (nonatomic) NSMutableArray *pixelsArray;
@property (nonatomic) NSMutableArray *pixelsArrayYPbPr;
@property (nonatomic) NSString *filename;
@property (nonatomic) NSString *filenameWithoutExtension;

-(id) initWithImageFile:(NSString*)filePath;
-(void) writeImageToDirectoryPath:(NSString*)dirPath ForImageType:(ImageType)imageType;
-(void) fadeImageToGrayToDirectoryPath:(NSString*)dirPath
                          ForImageType:(ImageType)imageType
                        NumberOfImages:(int)numberOfImages;
-(void) writeFloydSteinbergDitheringToDirectoryPath:(NSString*) dirPath;
-(void) writeFloydSteinbergColorDitheringToDirectoryPath:(NSString*) dirPath;

@end
