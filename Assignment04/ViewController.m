//
//  ViewController.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/3/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "ViewController.h"
#import "Pixel.h"
@interface ViewController (){
    float curentAlpha;
}

@end

@implementation ViewController
@synthesize orginalImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    NSString *imageFile       = @"/Users/khaledalyousefi/Dropbox/CSC-505/Homeworks/rose.png";
    NSString *outputDirectory = @"/Users/khaledalyousefi/Documents/Homeworks" ;
    
    // PART I  : create sequence of png files that fade from color image into gray image discarding Pb and Pr components
    [self createGrayFadeImagesFromFile:imageFile ToPathDirectory:outputDirectory NumberOfImages:10 ForImageType:YChannel];
    
    // PART II : create sequence of png files that fade from color image into gray image for YPbPr space
    
    // PART III: convert an 8-bit gray scale image to a 1-bit dithered binary image using the Floyd-Steinberg algorithm
    
    
}




-(void) FloydSteinbergDithering:(NSArray*)pixelMap ToPathFile:(NSString*)targetPath
{
    //Pixel *imagepxels[width][height];
    
    UIColor *currentColor;
    Pixel *currentPixel;
    int x,y,red,green,blue,alpha;
    
    UIGraphicsBeginImageContext(CGSizeMake(_width, _height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
    
    for (int i=0; i<[pixelMap count]; i++) {
        currentPixel = [pixelMap objectAtIndex:i];
        x     = currentPixel.point.x;
        y     = currentPixel.point.y;
        red   = currentPixel.red;
        green = currentPixel.green;
        blue  = currentPixel.blue;
        alpha = currentPixel.alpha;
        currentColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
        CGContextSetFillColorWithColor(context, [currentColor CGColor]);
        CGContextFillRect(context, CGRectMake(x, y, 1.0, 1.0));
        // NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);
    }
    
    // Write context to UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Write the image to the file
    [UIImagePNGRepresentation(image) writeToFile:targetPath atomically:YES];
}


-(NSArray*) readImageFile:(NSString*)filePath
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath: filePath];
    NSMutableArray *pixelMap = [[NSMutableArray alloc]init];
    int red,green,blue,alpha,pixelInfo;
    Pixel *currentPixel;
    
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
                
                currentPixel = [[Pixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue Alpha:alpha];
                [pixelMap addObject:currentPixel];
            }
        }
        
        return pixelMap;
    }
}

-(void) writeImageArray:(NSArray*)pixelMap ToPathFile:(NSString*)targetPath ForImageType:(ImageType)imageType
{    
    UIColor *currentColor;
    Pixel *currentPixel;
    int x,y,red,green,blue,alpha;
    
    UIGraphicsBeginImageContext(CGSizeMake(_width, _height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, CGRectMake(0, 0, _width, _height));
    
    for (int i=0; i<[pixelMap count]; i++) {
        currentPixel = [pixelMap objectAtIndex:i];
        x     = currentPixel.point.x;
        y     = currentPixel.point.y;
        red   = currentPixel.red;
        green = currentPixel.green;
        blue  = currentPixel.blue;
        alpha = currentPixel.alpha;
        
        if (imageType == YChannel)
        {
            int Y  =  0.299*red + 0.587*green + 0.114*blue;
            
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
        // NSLog(@"RGB:(%d,%d,%d) point:(%d,%d)",red,green,blue,x,y);
    }
    
    // Write context to UIImage
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Write the image to the file
    [UIImagePNGRepresentation(image) writeToFile:targetPath atomically:YES];
}

-(void) createGrayFadeImagesFromFile:(NSString*)file ToPathDirectory:(NSString*)targetDir
                       NumberOfImages:(int)numberOfImages ForImageType:(ImageType)imageType
{
    
    NSString *targetPath;
    NSArray *pixelMap = [self readImageFile:file];
    
    for (float i=1; i<=numberOfImages; i++) {
        // Name the output file
        if      (i<10)  targetPath = [NSString stringWithFormat:@"%@/rose00%.0f.png",targetDir,i];
        else if (i<100) targetPath = [NSString stringWithFormat:@"%@/rose0%.0f.png",targetDir,i];
        else            targetPath = [NSString stringWithFormat:@"%@/rose%.0f.png",targetDir,i];
        
        // Alpha-Blend
        curentAlpha = i/numberOfImages;
        if (imageType == YChannel)
            [self writeImageArray:pixelMap ToPathFile:targetPath ForImageType:YChannel];
        else if (imageType == YPbPrChannel)
            [self writeImageArray:pixelMap ToPathFile:targetPath ForImageType:YPbPrChannel];
    }
}





-(void) createGrayFadeImagesFromArray2:(NSArray*)pixelMap ToPathDirectory:(NSString*)targetDir NumberOfImages:(int)numberOfImages
{
    // read Image's Width & Height
    int width=0,height=0;
    for (Pixel *pixel in pixelMap) {
        if (pixel.point.x > width)  width  = pixel.point.x;
        if (pixel.point.y > height) height = pixel.point.y;
    }
    
    NSLog(@"%d,%d",width,height);
    UIColor *currentColor;
    Pixel *currentPixel;
    int x,y,red,green,blue,alpha,Y;
    NSString *targetPath;
    
    for (float i=1; i<=numberOfImages; i++) {
        // Creating image
        if      (i<10)  targetPath = [NSString stringWithFormat:@"%@/rose00%.0f.png",targetDir,i];
        else if (i<100) targetPath = [NSString stringWithFormat:@"%@/rose0%.0f.png",targetDir,i];
        else            targetPath = [NSString stringWithFormat:@"%@/rose%.0f.png",targetDir,i];
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
        
        curentAlpha = i/numberOfImages;
        for (int j=0; j<[pixelMap count]; j++){
            currentPixel = [pixelMap objectAtIndex:j];
            x     = currentPixel.point.x;
            y     = currentPixel.point.y;
            red   = currentPixel.red;
            green = currentPixel.green;
            blue  = currentPixel.blue;
            alpha = currentPixel.alpha;
            Y  =  0.299*red + 0.587*green + 0.114*blue;
            
            // Alpha-Blending
            red   = (1-curentAlpha) * red   + curentAlpha * Y;
            green = (1-curentAlpha) * green + curentAlpha * Y;
            blue  = (1-curentAlpha) * blue  + curentAlpha * Y;
            
            currentColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
            CGContextSetFillColorWithColor(context, [currentColor CGColor]);
            CGContextFillRect(context, CGRectMake(x, y, 1.0, 1.0));
        }
        // Write context to UIImage
        UIImage* imageTransparent = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Write the image to the file
        [UIImagePNGRepresentation(imageTransparent) writeToFile:targetPath atomically:YES];
    }
}



-(void) generatePNGFiles1ForFilePath:(UIImage*)image
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    int pixelInfo;
    
    int width  = image.size.width;
    int height = image.size.height;
    
    UIColor *currentColor;
    UInt8 red,green,blue,alpha;
    unsigned int Y;
    
    int numberOfPNGFiles = 100;
    
    for (float i=95; i<=numberOfPNGFiles; i++) {
        
        // Creating image
        NSString *targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/Homeworks/rose%.0f.png",i];
        if (i<10)
            targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/Homeworks/rose00%0.f.png",i];
        else if (i<100)
            targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/Homeworks/rose0%0.f.png",i];
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
        curentAlpha = i/numberOfPNGFiles;
        
        for (int x=1; x<width; x++) {
            for (int y=1; y<height; y++) {
                pixelInfo = ((width  * y) + x ) * 4; // The image is png
                
                red   = data[pixelInfo];
                green = data[pixelInfo + 1];
                blue  = data[pixelInfo + 2];
                alpha = data[pixelInfo + 3];
                
                Y  =  0.299*red + 0.587*green + 0.114*blue;
                
                red   = (1-curentAlpha) * red   + curentAlpha * Y;
                green = (1-curentAlpha) * green + curentAlpha * Y;
                blue  = (1-curentAlpha) * blue  + curentAlpha * Y;
                
                currentColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
                
                //NSLog(@"RGB:(%d,%d,%d) RGB:(%d,%d,%d)",red,green,blue,r,b,g);
                //NSLog(@"RGB:(%d,%d,%d) Y:%d Pb:%d Pr:%d",red,green,blue,Y,Pb,Pr);
                
                CGContextSetFillColorWithColor(context, [currentColor CGColor]);
                CGContextFillRect(context, CGRectMake(x, y, 1.0, 1.0));
            }
        }
        // Write context to uiimage
        UIImage* imageTransparent = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Write the image to the file
        [UIImagePNGRepresentation(imageTransparent) writeToFile:targetPath atomically:YES];
    }
}

-(void) generatePNGFiles2ForFilePath:(UIImage*)image
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    int pixelInfo;
    
    int width  = image.size.width;
    int height = image.size.height;
    
    NSMutableArray *pixelMap = [[NSMutableArray alloc]init];
    Pixel *currentPixel;
    UIColor *currentColor;
    UInt8 red,green,blue,alpha;
    unsigned int Y,Pb,Pr;
    UInt8 r,g,b;
    int numberOfPNGFiles = 3;
    
    for (float i=1; i<=numberOfPNGFiles; i++) {
        // Creating image
        NSString *targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/Homeworks/rose%.0f.png",i];
        if (i<10)
            targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/Homeworks/rose00%0.f.png",i];
        else if (i<100)
            targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/Homeworks/rose0%0.f.png",i];
        
        UIGraphicsBeginImageContext(CGSizeMake(width, height));
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, CGRectMake(0, 0, width, height));
        
        for (int x=1; x<width; x++) {
            for (int y=1; y<height; y++) {
                pixelInfo = ((width  * y) + x ) * 4; // The image is png
                
                red   = data[pixelInfo];
                green = data[pixelInfo + 1];
                blue  = data[pixelInfo + 2];
                alpha = data[pixelInfo + 3];
                
                Y  =  0.299*red + 0.587*green + 0.114*blue;
                Pb = -0.168*red - 0.331*green + 0.500*blue;
                Pr =  0.500*red - 0.418*green - 0.081*blue;
                
                r = 1.000*Y + 0.000*Pb + 1.402*Pr;
                g = 1.000*Y - 0.344*Pb - 0.714*Pr;
                b = 1.000*Y + 1.772*Pb + 0.000*Pr;
                
                r = (float)(1-(i/100)) * red   + (float)i/100 * r;
                g = (float)(1-(i/100)) * green + (float)i/100 * g;
                b = (float)(1-(i/100)) * blue  + (float)i/100 * b;
                
                //NSLog(@"RGB:(%d,%d,%d) RGB:(%d,%d,%d)",red,green,blue,r,b,g);
                //NSLog(@"RGB:(%d,%d,%d) Y:%d Pb:%d Pr:%d",red,green,blue,Y,Pb,Pr);
                currentColor = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:alpha];
                
                // NSString *targetPath = [NSString stringWithFormat:@"/Users/khaledalyousefi/Documents/%@",filename];
                
                currentPixel = [[Pixel alloc]initWithX:x Y:y Red:red Green:green Blue:blue Alpha:alpha];
                [pixelMap addObject:currentPixel];
                CGContextSetFillColorWithColor(context, [currentColor CGColor]);
                CGContextFillRect(context, CGRectMake(x, y, 1.0, 1.0));
            }
        }
        
        // Write context to uiimage
        UIImage* imageTransparent = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // Write the image to the file
        [UIImagePNGRepresentation(imageTransparent) writeToFile:targetPath atomically:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
