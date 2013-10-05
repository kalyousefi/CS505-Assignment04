//
//  Pixel.h
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/4/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Pixel : NSObject

@property CGPoint point;
@property int red;
@property int green;
@property int blue;
@property int alpha;

- (id)initWithX:(int)x Y:(int)y Red:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha;
+ (int)getWidth;
+ (int)getHeight;
@end
