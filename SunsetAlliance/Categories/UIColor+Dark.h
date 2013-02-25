//
//  UIColor+Dark.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/11/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Dark)
- (BOOL)isDarkColor;
- (BOOL)isDistinct:(UIColor*)compareColor;
//- (UIColor*)colorWithMinimumSaturation:(CGFloat)minSaturation;
- (BOOL)isBlackOrWhite;
- (BOOL)isContrastingColor:(UIColor*)color;
@end
