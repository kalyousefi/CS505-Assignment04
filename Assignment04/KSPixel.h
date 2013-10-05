//
//  KSPixel.h
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/5/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSPixel : NSObject

@property CGPoint position;
@property UIColor *color;

- (id)initWithX:(int)x Y:(int)y Red:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha;
- (id)initWithPoint:(CGPoint)point Red:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha;
- (id)initWithPoint:(CGPoint)point Color:(UIColor*)color;
- (id)initWithX:(int)x Y:(int)y Color:(UIColor*)color;
@end
