//
//  UIColor+Dark.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/11/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "UIColor+Dark.h"

@implementation UIColor (Dark)

- (BOOL)isDarkColor
{
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    CGFloat lum = 0.2126 * r + 0.7152 * g + 0.0722 + b;
    
    if (lum < 0.5) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isDistinct:(UIColor*)compareColor
{
    CGFloat r,g,b,a;
    CGFloat r1,g1,b1,a1;
    
    [self getRed:&r green:&g blue:&b alpha:&a];
    [compareColor getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    
    CGFloat threshold = 0.25;
    
    if (fabs(r - r1) > threshold ||
        fabs(g - g1) > threshold ||
        fabs(b - b1) > threshold ||
        fabs(a - a1) > threshold) {
        if ( fabs(r - g) < 0.03 && fabs(r - b) < 0.03 ) {
            if ( fabs(r1 - g1) < 0.03 && fabs(r1 - b1) < 0.03 ) {
                return NO;
            }
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)isBlackOrWhite
{
    CGFloat r,g,b,a;
    [self getRed:&r green:&g blue:&b alpha:&a];
    return (r > 0.91 && g > 0.91 && b > 0.91) || (r < 0.09 && g < 0.09 && b < 0.09);
}

- (BOOL)isContrastingColor:(UIColor*)color
{
    if ( self != nil && color != nil) {
        CGFloat br, bg, bb, ba;
        CGFloat fr, fg, fb, fa;
        
        [self getRed:&br green:&bg blue:&bb alpha:&ba];
        [color getRed:&fr green:&fg blue:&fb alpha:&fa];
        
        CGFloat bLum = 0.2126 * br + 0.7152 * bg + 0.0722 * bb;
        CGFloat fLum = 0.2126 * fr + 0.7152 * fg + 0.0722 * fb;
        
        CGFloat contrast = 0.;
        
        if ( bLum > fLum ) {
            contrast = (bLum + 0.05) / (fLum + 0.05);
        } else {
            contrast = (fLum + 0.05) / (bLum + 0.05);
        }
        
        return contrast > 1.6;
    }
    
    return YES;
}

@end
