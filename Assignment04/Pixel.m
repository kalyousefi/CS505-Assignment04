//
//  Pixel.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/4/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "Pixel.h"
static int width;
static int height;

@implementation Pixel

- (id)initWithX:(int)x Y:(int)y Red:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    _point = CGPointMake(x, y);
    _red   = red;
    _green = green;
    _blue  = blue;
    _alpha = alpha;
    
    return self;
}

+ (int)getWidth
{
    return width;
}
+ (int)getHeight
{
    return height;
}

- (void)getColorsFroPoint:(CGPoint)point
{
    
}

@end
