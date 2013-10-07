//
//  KSImage.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "KSImage.h"

@interface KSImage (){
    NSMutableArray *tempPixelsArray;
}
@end

@implementation KSImage

- (id)initWithImageFile:(NSString*)filePath
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath: filePath];
    _pixelsArray      = [[NSMutableArray alloc]init];
    tempPixelsArray      = [[NSMutableArray alloc]init];
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
                
                currentPixel = [[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue];
                [_pixelsArray      addObject:[[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue]];
            }
        }
    }
    _colorSpace = RGB;
    _filename = [filePath lastPathComponent];
    _filenameWithoutExtension = [[_filename componentsSeparatedByString:@"."]objectAtIndex:0];
    return self;
}

- (id)readImage:(NSString*)filePath
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath: filePath];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
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
        
        int width  = image.size.width;
        int height = image.size.height;
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
        for (int x=1; x<=width; x++) {
            for (int y=1; y<=height; y++) {
                pixelInfo = ((width  * y) + x ) * 4; // The image is png
                
                red   = data[pixelInfo];
                green = data[pixelInfo + 1];
                blue  = data[pixelInfo + 2];
                alpha = data[pixelInfo + 3];
                //NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);
                
                currentPixel = [[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue];
                [array      addObject:[[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue]];
            }
        }
    }
    _colorSpace = RGB;
    _filename = [filePath lastPathComponent];
    _filenameWithoutExtension = [[_filename componentsSeparatedByString:@"."]objectAtIndex:0];
    return self;
}



-(void) writeImageArray:(NSArray*) pixelArray ToPath:(NSString*)dirPath
{
    UIColor *currentColor;
    KSPixel *pixel;
    
    UIGraphicsBeginImageContext(CGSizeMake(_width, _height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
    
    for (int i=0; i<[pixelArray count]; i++) {
        pixel = [pixelArray objectAtIndex:i];
        
        // Draw this pixel
        currentColor = [UIColor colorWithRed:pixel.red/255.0 green:pixel.green/255.0 blue:pixel.blue/255.0 alpha:1];
        CGContextSetFillColorWithColor(context, [currentColor CGColor]);
        CGContextFillRect(context, CGRectMake(pixel.x, pixel.y, 1.0, 1.0));
    }
    
    // Write context to UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Write UIImage to a file
    [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"%@/%@",dirPath,_filename] atomically:YES];
}

-(void) fadeGrayToPath:(NSString*) dirPath NumberOfImages:(int)numberOfImages
{
    KSPixel *pixel;
    UInt8 red,green,blue,Y;
    for (int i=0; i<=numberOfImages; i++) {
        // Name the output file
        _filename = [NSString stringWithFormat:@"%@%03d.png",_filenameWithoutExtension,i];
        // Alpha-Blend
        
        float curentAlpha = (float)i/numberOfImages;
        
        for (int j=0; j<[_pixelsArray count]; j++) {
            pixel = [_pixelsArray objectAtIndex:j];
            red = pixel.red;
            green = pixel.green;
            blue = pixel.blue;
            
            Y  =  0.299*red + 0.587*green + 0.114*blue;
            // Alpha-Blending
            red   = (1-curentAlpha) * red   + curentAlpha * Y;
            green = (1-curentAlpha) * green + curentAlpha * Y;
            blue  = (1-curentAlpha) * blue  + curentAlpha * Y;
            //NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);

            [pixel setRed:red];
            [pixel setGreen:green];
            [pixel setBlue:blue];
            
            [tempPixelsArray addObject:pixel];
            
        }
        
        [self writeImageArray:tempPixelsArray ToPath:dirPath];
        [tempPixelsArray removeAllObjects];
    }
}

-(void) morphToImage:(KSImage*) image2 ToPath:(NSString*) dirPath NumberOfImages:(int)numberOfImages
{
    UInt8 red,green,blue;
    int x,y;
    
    int width  = MAX(image2.width, _width);
    int height = MAX(image2.height, _height);
    
    UIColor *array1[_width][_height];
    for (KSPixel *pixel in _pixelsArray) {
        x = pixel.x;
        y = pixel.y;
        if (x<_width && y<_height) {
            UIColor *color = [UIColor colorWithRed:pixel.red/255.0 green:pixel.green/255.0 blue:pixel.blue/255.0 alpha:1];
            array1[x][y] = color;
        }
    }
   
    UIColor *array2[image2.width][image2.height];
    for (KSPixel *pixel in image2.pixelsArray) {
        x = pixel.x;
        y = pixel.y;
        if (x<_width && y<_height) {
            UIColor *color = [UIColor colorWithRed:pixel.red/255.0 green:pixel.green/255.0 blue:pixel.blue/255.0 alpha:1];
            array2[x][y] = color;
        }
    }
        
    for (int i=0; i<=numberOfImages; i++) {
        // Name the output file
        _filename = [NSString stringWithFormat:@"%@%03d.png",_filenameWithoutExtension,i];

        float curentAlpha = (float)i/numberOfImages;
        
        for (int x=1; x<=width; x++) {
            for (int y=1; y<=height; y++) {
                if (!(x >= _width || y >= _height || x >= image2.width || y >= image2.height)) {

                    const CGFloat* colorRGB1 = CGColorGetComponents([array1[x][y] CGColor]);
                    const CGFloat* colorRGB2 = CGColorGetComponents([array2[x][y] CGColor]);
                    int red1 = colorRGB1[0]*255,   green1 = colorRGB1[1]*255,  blue1 = colorRGB1[2]*255;
                    int red2 = colorRGB2[0]*255,   green2 = colorRGB2[1]*255,  blue2 = colorRGB2[2]*255;
                    
                    // Alpha-Blending
                    red   = (1-curentAlpha) * red1   + curentAlpha * red2;
                    green = (1-curentAlpha) * green1 + curentAlpha * green2;
                    blue  = (1-curentAlpha) * blue1  + curentAlpha * blue2;
 
                    //NSLog(@"image1:(%d,%d,%d) image2:(%d,%d,%d)",red1,red2,green1,green2,blue1,blue2);
                    
                    KSPixel *currentPixel = [[KSPixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue];
                    [tempPixelsArray addObject:currentPixel];
                }
                
            }
        }

        
        [self writeMorphImageArray:tempPixelsArray ToPath:dirPath Width:width Height:height];
        [tempPixelsArray removeAllObjects];
    }
}

-(void) writeMorphImageArray:(NSArray*) pixelArray ToPath:(NSString*)dirPath Width:(int)width Height:(int) height
{
    UIColor *currentColor;
    KSPixel *pixel;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    for (int i=0; i<[pixelArray count]; i++) {
        pixel = [pixelArray objectAtIndex:i];
        
        // Draw this pixel
        currentColor = [UIColor colorWithRed:pixel.red/255.0 green:pixel.green/255.0 blue:pixel.blue/255.0 alpha:1];
        CGContextSetFillColorWithColor(context, [currentColor CGColor]);
        CGContextFillRect(context, CGRectMake(pixel.x, pixel.y, 1.0, 1.0));
    }
    
    // Write context to UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Write UIImage to a file
    [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"%@/%@",dirPath,_filename] atomically:YES];
}


-(void) convertToColorSpace:(ColorSpace)colorSpace
{
    // Read Image Pixels
    for (int i=0; i<[_pixelsArray count]; i++) {
        KSPixel *pixel = [_pixelsArray objectAtIndex:i];
       
        if (colorSpace == YPbPr) {
            float Y  =  (float)0.299*pixel.red + (float)0.587*pixel.green + (float)0.114*pixel.blue;
            float Pb = (float)-0.168*pixel.red - (float)0.331*pixel.green + (float)0.500*pixel.blue;
            float Pr =  (float)0.500*pixel.red - (float)0.418*pixel.green - (float)0.081*pixel.blue;
            
            pixel = [[KSPixel alloc]initWithX:pixel.x Y:pixel.y Red:Y Green:Pb Blue:Pr];
        }
        else if (colorSpace == RGB)
        {
            float Y = pixel.red, Pb = pixel.green, Pr = pixel.blue;
            int red   = 1.000*Y + 0.000*Pb + 1.402*Pr;
            int green = 1.000*Y - 0.344*Pb - 0.714*Pr;
            int blue  = 1.000*Y + 1.772*Pb + 0.000*Pr;
            pixel = [[KSPixel alloc]initWithX:pixel.x Y:pixel.y Red:red Green:green Blue:blue];
        }
        
        [_pixelsArray replaceObjectAtIndex:i withObject:pixel];
    }
    _colorSpace = colorSpace;
}

-(void) ditherBlackWhiteToPath:(NSString*) dirPath
{
    // Convert NSArray pixelsArray to C array
    int pixelsArray[_width][_height];
    int x,y,Y;
    
    // Change image to gray scale
    for (KSPixel *pixel in _pixelsArray) {
        x = pixel.x;
        y = pixel.y;
        
        Y  =  0.299*pixel.red + 0.587*pixel.green + 0.114*pixel.blue;
        
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
                              initWithX:x Y:y Red:pixelsArray[x][y] Green:pixelsArray[x][y] Blue:pixelsArray[x][y]];
            [_pixelsArray addObject:pixel];
        }
    }
    
    _filename = [NSString stringWithFormat:@"%@_FSDither.png"  ,_filenameWithoutExtension];
    
    [self writeImageArray:_pixelsArray ToPath:dirPath];
}

-(void) ditherSixColorsToPath:(NSString*) dirPath
{
    UIColor *pixelsArray[_width][_height];
    int x,y;
    
    // convert NSArray to c array
    for (KSPixel *pixel in _pixelsArray) {        
        x = pixel.x;
        y = pixel.y;
        if (x<_width && y<_height) {
            UIColor *color = [UIColor colorWithRed:pixel.red/255.0 green:pixel.green/255.0 blue:pixel.blue/255.0 alpha:1];
            pixelsArray[x][y] = color;
        }
    }

    // remove all image pixels to assign the new pixels
    [_pixelsArray removeAllObjects];
    
    int errorR,errorG,errorB,displayed;
    
    for (y=1; y<_height; y++) {
        for (x=1; x<_width; x++) {
            
            // Retrieve color components
            const CGFloat* colorRGB = CGColorGetComponents([pixelsArray[x][y] CGColor]);
            int red = colorRGB[0]*255,   green = colorRGB[1]*255,  blue = colorRGB[2]*255, alpha = colorRGB[3]*255;

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
    [self writeImageArray:_pixelsArray ToPath:dirPath];
}

-(void) resizeImage:(int)stepSize ToPath:(NSString*)dirPath
{
    UIColor *currentColor;
    KSPixel *pixel;
    UInt8 red,green,blue;
    
    UIGraphicsBeginImageContext(CGSizeMake(_width*stepSize, _height*stepSize));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, _width*stepSize, _height*stepSize));
    
    for (int i=0; i<[_pixelsArray count]; i++) {
        pixel = [_pixelsArray objectAtIndex:i];
        red = pixel.red;
        green = pixel.green;
        blue = pixel.blue;
        
        // Draw this pixel
        currentColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1];
        CGContextSetFillColorWithColor(context, [currentColor CGColor]);
        CGContextFillRect(context, CGRectMake(pixel.x*stepSize, pixel.y*stepSize, stepSize, stepSize));
    }
    
    // Write context to UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Write UIImage to a file
    [UIImagePNGRepresentation(image) writeToFile:[NSString stringWithFormat:@"%@/%@",dirPath,_filename] atomically:YES];
}
@end
