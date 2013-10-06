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
    _pixelsArray      = [[NSMutableArray alloc]init];
    _pixelsArrayYPbPr = [[NSMutableArray alloc]init];
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
                
                UInt8 Y  =  0.299*red + 0.587*green + 0.114*blue;
                UInt8 Pb = -0.168*red - 0.331*green + 0.500*blue;
                UInt8 Pr =  0.500*red - 0.418*green - 0.081*blue;
                
                currentPixel = [[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue Alpha:alpha];
                [_pixelsArray      addObject:[[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue Alpha:alpha]];
                [_pixelsArrayYPbPr addObject:[[KSPixel alloc]initWithX:x Y:y Red:Y   Green:Pb    Blue:Pr   Alpha:alpha]];
            }
        }
    }
    _filename = [filePath lastPathComponent];
    _filenameWithoutExtension = [[_filename componentsSeparatedByString:@"."]objectAtIndex:0];
    curentAlpha = 0;
    return self;
}


-(void) writeImageToDirectoryPath:(NSString*)dirPath ForImageType:(ImageType)imageType
{
    UIColor *currentColor;
    KSPixel *currentPixel;
    int x,y,red,green,blue,alpha,Y;
    
    UIGraphicsBeginImageContext(CGSizeMake(_width, _height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
    
    for (int i=0; i<[_pixelsArray count]; i++) {
        if      (imageType == YChannel || imageType==RGB)     currentPixel = [_pixelsArray objectAtIndex:i];
        else if (imageType == YPbPrChannel)                   currentPixel = [_pixelsArrayYPbPr objectAtIndex:i];
      
        x     = currentPixel.position.x;
        y     = currentPixel.position.y;
        
        // Retrieve color components
        const CGFloat* colorRGB = CGColorGetComponents([currentPixel.color CGColor]);
        red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
        
        Y  =  0.299*red + 0.587*green + 0.114*blue;
        
        // Alpha-Blending
        red   = (1-curentAlpha) * red   + curentAlpha * Y;
        green = (1-curentAlpha) * green + curentAlpha * Y;
        blue  = (1-curentAlpha) * blue  + curentAlpha * Y;
        //NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);

        // Draw this pixel
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
    NSString *targetPath = [NSString stringWithFormat:@"%@/%@",dirPath,_filename]; // XXX Change filename
    [UIImagePNGRepresentation(image) writeToFile:targetPath atomically:YES];
}

-(void) fadeImageToGrayToDirectoryPath:(NSString*) dirPath
                          ForImageType:(ImageType) imageType
                        NumberOfImages:(int)       numberOfImages
{
    
    for (float i=0; i<=numberOfImages; i++) {
        // Name the output file
        if      (i<10)  _filename = [NSString stringWithFormat:@"%@00%.0f.png",_filenameWithoutExtension,i];
        else if (i<100) _filename = [NSString stringWithFormat:@"%@0%.0f.png" ,_filenameWithoutExtension,i];
        else            _filename = [NSString stringWithFormat:@"%@%.0f.png"  ,_filenameWithoutExtension,i];
        
        // Alpha-Blend
        curentAlpha = i/numberOfImages;
        
        [self writeImageToDirectoryPath:dirPath ForImageType:imageType];
    }
}

-(void) writeFloydSteinbergDitheringToDirectoryPath:(NSString*) dirPath
{
    curentAlpha = 1; // To set Gray level
    
    // Convert NSArray pixelsArray to C array
    int pixelsArray[_width][_height];
    int x,y,red,green,blue,alpha,Y;
    
    // Change image to gray scale
    for (KSPixel *pixel in _pixelsArray) {
        x = pixel.position.x;
        y = pixel.position.y;
        // Retrieve color components
        const CGFloat* colorRGB = CGColorGetComponents([pixel.color CGColor]);
        red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
        Y  =  0.299*red + 0.587*green + 0.114*blue;
        
        pixelsArray[x][y] = Y;
    }
    
    [_pixelsArray removeAllObjects];
    
    int error,displayed;
    
    for (y=1; y<_height; y++) {
        for (x=1; x<_width; x++) {
            if (pixelsArray[x][y] > 128) displayed = 255;
            else                         displayed = 0;
            
            error = pixelsArray[x][y] - displayed;
            pixelsArray[x][y] = displayed;
            
            if (x + 1 < _width)     pixelsArray[x+1][y]   += 7 * error / 16 ;
            if (y + 1 < _height) {
                if (x - 1 > 0)      pixelsArray[x-1][y+1] += 3 * error / 16 ;
                pixelsArray[x]  [y+1] += 5 * error / 16 ;
                if (x + 1 < _width) pixelsArray[x+1][y+1] += 1 * error / 16 ;
            }
            
            KSPixel *pixel = [[KSPixel alloc]
                              initWithX:x Y:y Red:pixelsArray[x][y] Green:pixelsArray[x][y] Blue:pixelsArray[x][y] Alpha:1];
            [_pixelsArray addObject:pixel];
        }
    }
    
    _filename = [NSString stringWithFormat:@"%@_FSDither.png"  ,_filenameWithoutExtension];
    
    [self writeImageToDirectoryPath:dirPath ForImageType:RGB];
}

-(void) writeFloydSteinbergColorDitheringToDirectoryPath:(NSString*) dirPath
{
    curentAlpha = 1;
    
    UIColor *pixelsArray[_width][_height];
    int x,y;
    CGFloat red,green,blue,alpha;
    
    // Change image to gray scale
    for (KSPixel *pixel in _pixelsArray) {
        
        x = pixel.position.x;
        y = pixel.position.y;
        if (x<_width && y<_height) {
            pixelsArray[x][y] = pixel.color;
        }
    }
    
    [_pixelsArray removeAllObjects];
    
    int errorR,errorG,errorB,displayed;
    for (y=1; y<_height; y++) {
        for (x=1; x<_width; x++) {
            //NSLog(@"545445x=%d y=%d",x,y);
            // Retrieve color components
            const CGFloat* colorRGB = CGColorGetComponents([pixelsArray[x][y] CGColor]);
            red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
            
            if (red > 128) displayed = 255;
            else             displayed = 0;
            errorR = red - displayed;
            red = displayed;
            
            if (green > 128) displayed = 255;
            else             displayed = 0;
            errorG = green - displayed;
            green = displayed;
            
            if (blue > 128) displayed = 255;
            else             displayed = 0;
            errorB = blue - displayed;
            blue = displayed;
            
            pixelsArray[x][y] = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
            
            if (x + 1 < _width){
                const CGFloat* colorRGB = CGColorGetComponents([pixelsArray[x+1][y] CGColor]);
                red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
                
                red   += 7 * errorR / 16;
                green += 7 * errorG / 16;
                blue  += 7 * errorB / 16;
                
                pixelsArray[x+1][y] = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
            }
            if (y + 1 < _height) {
                if (x - 1 > 0){
                    const CGFloat* colorRGB = CGColorGetComponents([pixelsArray[x-1][y+1] CGColor]);
                    red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
                    
                    red   += 3 * errorR / 16;
                    green += 3 * errorG / 16;
                    blue  += 3 * errorB / 16;
                    
                    pixelsArray[x-1][y+1] = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
                }
                const CGFloat* colorRGB = CGColorGetComponents([pixelsArray[x][y+1] CGColor]);
                red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
                
                red   += 5 * errorR / 16;
                green += 5 * errorG / 16;
                blue  += 5 * errorB / 16;
                
                pixelsArray[x][y+1] = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
                
                if (x + 1 < _width) {
                    const CGFloat* colorRGB = CGColorGetComponents([pixelsArray[x+1][y+1] CGColor]);
                    red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;
                    
                    red   += 1 * errorR / 16;
                    green += 1 * errorG / 16;
                    blue  += 1 * errorB / 16;
                    
                    pixelsArray[x+1][y+1] = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
                    
                }
            }
            
            KSPixel *pixel = [[KSPixel alloc] initWithX:x Y:y Color:pixelsArray[x][y]];
            [_pixelsArray addObject:pixel];
        }
    }
    
    _filename = [NSString stringWithFormat:@"%@_FSDitherColor.png"  ,_filenameWithoutExtension];
    [self writeImageToDirectoryPath:dirPath ForImageType:RGB];
}


@end
