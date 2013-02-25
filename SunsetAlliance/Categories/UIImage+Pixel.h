//
//  UIImage+Pixel.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/11/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MM_UIIMAGE_BYTES_PER_PIXEL 4u

@interface UIImage (Pixel)

@property (strong, nonatomic, readwrite) UIColor *backgroundColor;
@property (strong, nonatomic, readwrite) UIColor *primaryColor;
@property (strong, nonatomic, readwrite) UIColor *secondaryColor;
@property (strong, nonatomic, readwrite) UIColor *detailColor;

- (void)analyze;
@end

@interface CountedColor : NSObject

@property (assign, nonatomic, readwrite) NSUInteger count;
@property (strong, nonatomic, readwrite) UIColor *color;

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count;

@end

@interface ColorSets : NSObject

@property (nonatomic, strong) NSCountedSet *imageColors;
@property (nonatomic, strong) NSArray *sortedImageColors;
@property (nonatomic, strong) NSCountedSet *edgeColors;
@property (nonatomic, strong) NSArray *sortedEdgeColors;

@end