//
//  KSPixel.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "KSPixel.h"

@implementation KSPixel

- (id)initWithX:(int)x Y:(int)y Red:(int)red Green:(int)green Blue:(int)blue
{
    _x      = x;
    _y      = y;
    _red    = red;
    _green  = green;
    _blue   = blue;
    
    return self;
}

- (id)initWithPoint:(CGPoint)position Red:(int)red Green:(int)green Blue:(int)blue
{
    _x      = position.x;
    _y      = position.y;
    _red    = red;
    _green  = green;
    _blue   = blue;
    
    return self;
}

- (id)initWithPoint:(CGPoint)position Color:(UIColor*)color
{
    _x      = position.x;
    _y      = position.y;
    const CGFloat* colorRGB = CGColorGetComponents([color CGColor]);
    _red = colorRGB[0]*255;
    _green = colorRGB[1]*255;
    _blue = colorRGB[2]*255;
    
    return self;
}

- (id)initWithX:(int)x Y:(int)y Color:(UIColor*)color
{
    _x      = x;
    _y      = y;
    const CGFloat* colorRGB = CGColorGetComponents([color CGColor]);
    _red = colorRGB[0]*255;
    _green = colorRGB[1]*255;
    _blue = colorRGB[2]*255;
    
    return self;
}
@end
