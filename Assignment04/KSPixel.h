//
//  KSPixel.h
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSPixel : NSObject

@property int x;
@property int y;
@property int red;
@property int green;
@property int blue;

- (id)initWithX:(int)x Y:(int)y Red:(int)red Green:(int)green Blue:(int)blue;
- (id)initWithPoint:(CGPoint)point Red:(int)red Green:(int)green Blue:(int)blue;
- (id)initWithPoint:(CGPoint)point Color:(UIColor*)color;
- (id)initWithX:(int)x Y:(int)y Color:(UIColor*)color;
@end
