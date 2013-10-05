//
//  KSImage.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "KSImage.h"

@interface KSImage (){
    float curentAlpha;
}
@end

@implementation KSImage

- (id)initWithImageFile:(NSString*)filePath
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath: filePath];
    _pixelsArray = [[NSMutableArray alloc]init];
    int red,green,blue,alpha,pixelInfo;
    KSPixel *currentPixel;
    
    if (file == nil) {
        NSLog(@"Failed to open file");
        return nil;
    }
    else
    {
        NSData *fileData = [file readDataToEndOfFile];
        UIImage *image = [[UIImage alloc]initWithData:fileData];
        CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
        const UInt8* data = CFDataGetBytePtr(pixelData);
        
        _width  = image.size.width;
        _height = image.size.height;
        
        UIGraphicsBeginImageContext(CGSizeMake(_width, _height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
        for (int x=1; x<=_width; x++) {
            for (int y=1; y<=_height; y++) {
                pixelInfo = ((_width  * y) + x ) * 4; // The image is png
                
                red   = data[pixelInfo];
                green = data[pixelInfo + 1];
                blue  = data[pixelInfo + 2];
                alpha = data[pixelInfo + 3];
                //NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);
                
                currentPixel = [[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue Alpha:alpha];
                [_pixelsArray addObject:currentPixel];
            }
        }
    }
    _filename = [filePath lastPathComponent];
    curentAlpha = 1;
    return self;
}


-(void) writeImageFile:(NSString*)filename ToDirectoryPath:(NSString*)dirPath ForImageType:(ImageType)imageType
{
    UIColor *currentColor;
    KSPixel *currentPixel;
    int x,y,red,green,blue,alpha,Y;
    
    UIGraphicsBeginImageContext(CGSizeMake(_width, _height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
    
    for (int i=0; i<[_pixelsArray count]; i++) {
        currentPixel = [_pixelsArray objectAtIndex:i];
        x     = currentPixel.position.x;
        y     = currentPixel.position.y;
        
        // Retrieve color components
        const CGFloat* colorRGB = CGColorGetComponents([currentPixel.color CGColor]);
        red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;        
        
        if (imageType == YChannel)
        {
            Y  =  0.299*red + 0.587*green + 0.114*blue;
            
            // Alpha-Blending
            red   = (1-curentAlpha) * red   + curentAlpha * Y;
            green = (1-curentAlpha) * green + curentAlpha * Y;
            blue  = (1-curentAlpha) * blue  + curentAlpha * Y;
        }
        else if (imageType == YPbPrChannel)
        {
            int Y  =  0.299*red + 0.587*green + 0.114*blue;
            int Pb = -0.168*red - 0.331*green + 0.500*blue;
            int Pr =  0.500*red - 0.418*green - 0.081*blue;
            
            int r = 1.000*Y + 0.000*Pb + 1.402*Pr;
            int g = 1.000*Y - 0.344*Pb - 0.714*Pr;
            int b = 1.000*Y + 1.772*Pb + 0.000*Pr;
            
            r = (float)(1-(i/100)) * red   + (float)i/100 * r;
            g = (float)(1-(i/100)) * green + (float)i/100 * g;
            b = (float)(1-(i/100)) * blue  + (float)i/100 * b;
        }
        
        
        currentColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
        CGContextSetFillColorWithColor(context, [currentColor CGColor]);
        CGContextFillRect(context, CGRectMake(x, y, 1.0, 1.0));
        //NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);
        //NSLog(@"RGB:(%f,%f,%f) point:(%d,%d)",colorRGB[0],colorRGB[1],colorRGB[2],x,y);
    }
    
    // Write context to UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Write the image to the file
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@",dirPath,filename];
    [UIImagePNGRepresentation(image) writeToFile:targetPath atomically:YES];
}

-(void) fadeImageToGrayToDirectoryPath:(NSString*) dirPath
                          ForImageType:(ImageType) imageType
                        NumberOfImages:(int)       numberOfImages
{
    
    NSString *fileNameWithoutExtension = [[_filename componentsSeparatedByString:@"."]objectAtIndex:0];
    NSString *filename;
    
    
    for (float i=1; i<=numberOfImages; i++) {
        // Name the output file
        if      (i<10)  filename = [NSString stringWithFormat:@"%@00%.0f.png",fileNameWithoutExtension,i];
        else if (i<100) filename = [NSString stringWithFormat:@"%@0%.0f.png" ,fileNameWithoutExtension,i];
        else            filename = [NSString stringWithFormat:@"%@%.0f.png"  ,fileNameWithoutExtension,i];
        
        // Alpha-Blend
        curentAlpha = i/numberOfImages;
        [self writeImageFile:filename ToDirectoryPath:dirPath ForImageType:imageType];
    }
}

-(void) writeFloydSteinbergDitheringToDirectoryPath:(NSString*) dirPath
{
    curentAlpha = 1;    
    
    int pixelsArray[_width][_height];
    int floydArray[_width][_height];
    int x,y,red,green,blue,alpha,Y;
    
    // Change image to gray scale
    for (KSPixel *pixel in _pixelsArray) {
        x = pixel.position.x;
        y = pixel.position.y;
        // Retrieve color components
        const CGFloat* colorRGB = CGColorGetComponents([pixel.color CGColor]);
        red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
        Y  =  0.299*red + 0.587*green + 0.114*blue;

        // Convert NSArray pixelsArray to C array
        pixelsArray[x][y] = Y;
        pixel.color = [UIColor colorWithRed:Y/255.0 green:Y/255.0 blue:Y/255.0 alpha:alpha];       
    }

    
    for (x=1; x<_width; x++) {
        for (y=1; y<_height; y++) {

            if (x>1 && x< _width && y>1 && y < _height) {
                if (pixelsArray[x][y] > 128) floydArray[x][y] = 0;
                else                         floydArray[x][y] = 255;
                    
            } else floydArray[x][y] = 0;
        }
    }
    
    [_pixelsArray removeAllObjects];
    
    for (x=1; x<_width; x++) {
        for (y=1; y<_height; y++) {
            KSPixel *pixel = [[KSPixel alloc]initWithX:x Y:y Red:floydArray[x][y] Green:floydArray[x][y] Blue:floydArray[x][y] Alpha:255];
            [_pixelsArray addObject:pixel];
        }
    }
    
    [self writeImageFile:_filename ToDirectoryPath:dirPath ForImageType:RGB];
    
    
}



@end
