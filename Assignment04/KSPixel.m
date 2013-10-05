//
//  KSPixel.m
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import "KSPixel.h"

@implementation KSPixel

- (id)initWithX:(int)x Y:(int)y Red:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    _position = CGPointMake(x, y);
    _color    = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
    
    return self;
}

- (id)initWithPoint:(CGPoint)position Red:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    _position = position;
    _color    = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
    
    return self;
}

- (id)initWithPoint:(CGPoint)position Color:(UIColor*)color
{
    _position = position;
    _color    = color;
    
    return self;
}

- (id)initWithX:(int)x Y:(int)y Color:(UIColor*)color
{
    _position = CGPointMake(x, y);
    _color    = color;
    
    return self;
}
@end
