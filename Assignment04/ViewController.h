//
//  ViewController.h
//  Assignment04
//
//  Created by Khaled Alyousefi on 10/3/13.
//  Copyright (c) 2013 Khaled Alyousefi. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, ColorSpace) {
    YChannel,
    YPbPrChannel
};
@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *orginalImage;
@property (strong, nonatomic) IBOutlet UIImageView *yGrayImage;
@property int width;
@property int height;

@end
