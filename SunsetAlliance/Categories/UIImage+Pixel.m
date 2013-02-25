//
//  UIImage+Pixel.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/11/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "UIImage+Pixel.h"
#import "UIColor+Dark.h"
#import <objc/runtime.h>

static char const kBackgroundColor;
static char const kPrimaryColor;
static char const kSecondaryColor;
static char const kDetailColor;

@implementation UIImage (Pixel)


- (UIColor*)getStoredColor:(char const*)colorConst
{
    UIColor *color = (UIColor*)objc_getAssociatedObject(self, colorConst);
    
    if (color == nil) {
        color = (UIColor*)objc_getAssociatedObject(self, colorConst);
    }
    
    return color;
}

- (void)setStoredColor:(UIColor*)color as:(char const*)colorConst
{
    objc_setAssociatedObject(self, colorConst, color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor*)backgroundColor
{
    return [self getStoredColor:&kBackgroundColor];
}

- (void)setBackgroundColor:(UIColor *)color
{
    [self setStoredColor:color as:&kBackgroundColor];
}

- (UIColor*)primaryColor
{
    return [self getStoredColor:&kPrimaryColor];
}

- (void)setPrimaryColor:(UIColor *)color
{
    [self setStoredColor:color as:&kPrimaryColor];
}

- (UIColor*)secondaryColor
{
    return [self getStoredColor:&kSecondaryColor];
}

- (void)setSecondaryColor:(UIColor *)color
{
    [self setStoredColor:color as:&kSecondaryColor];
}

- (UIColor*)detailColor
{
    return [self getStoredColor:&kDetailColor];
}

- (void)setDetailColor:(UIColor *)color
{
    [self setStoredColor:color as:&kDetailColor];
}

- (void)analyze
{
    ColorSets *colors = [self getColors];
    self.backgroundColor = [self determineBackgroundColorFromColors:colors];
    BOOL darkBackground = [self.backgroundColor isDarkColor];
    
    [self determineColorsFromColors:colors.sortedImageColors];
    
    if (darkBackground) {
        self.primaryColor = [UIColor whiteColor];
        self.secondaryColor = [UIColor whiteColor];
        self.detailColor = [UIColor whiteColor];
    } else {
        self.primaryColor = [UIColor blackColor];
        self.secondaryColor = [UIColor blackColor];
        self.detailColor = [UIColor blackColor];
    }

}

- (NSData *)getRawImageData
{
    CGImageRef imageRef = self.CGImage;
    NSUInteger width = CGImageGetWidth(imageRef);
    NSUInteger height = CGImageGetHeight(imageRef);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger dataSize = height * width * MM_UIIMAGE_BYTES_PER_PIXEL;
    unsigned char *rawData = malloc(dataSize);
    NSUInteger bytesPerRow = width * MM_UIIMAGE_BYTES_PER_PIXEL;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(rawData, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    NSData *rtn = [NSData dataWithBytes:rawData length:dataSize];
    
    return rtn;
}

- (UIColor*)colorFromData:(NSData*)imageData atX:(NSUInteger)x andY:(NSUInteger)y
{
    NSUInteger byteIndex = MM_UIIMAGE_BYTES_PER_PIXEL * (self.size.width * y + x);
    
    unsigned char rgbaData[4];
    NSRange range = { byteIndex, 4u };
    [imageData getBytes:rgbaData range:range];
    CGFloat red = rgbaData[0] / 255.0;
    CGFloat green = rgbaData[1] / 255.0;
    CGFloat blue = rgbaData[2] / 255.0;
    CGFloat alpha = rgbaData[3] / 255.0;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (ColorSets*)getColors
{
    ColorSets *colors = [[ColorSets alloc]init];
    colors.imageColors = [[NSCountedSet alloc]initWithCapacity:(self.size.width * self.size.height)];
    colors.edgeColors = [[NSCountedSet alloc] initWithCapacity:self.size.height];

    NSData *imageData = [self getRawImageData];
    
    for ( NSUInteger x = 0; x < self.size.width; x++ ) {
        for (NSUInteger y = 0; y < self.size.height; y++ ) {
            UIColor *color = [self colorFromData:imageData atX:x andY:y];
            [colors.imageColors addObject:color];
            if (x == 0) { // if first row, add to edge collection
                [colors.edgeColors addObject:color];
            }
        }
    }
    
    colors.sortedImageColors = [self getSortedColorsFromColors:colors.imageColors];
    colors.sortedEdgeColors = [self getSortedColorsFromColors:colors.edgeColors];
    
    return colors;
}

- (NSArray*)getSortedColorsFromColors:(NSCountedSet*)colors
{
    NSEnumerator *edgeEnum = [colors objectEnumerator];
    UIColor *currentColor = nil;
    NSMutableArray *sortedEdgeColors = [NSMutableArray arrayWithCapacity:[colors count]];
    
    while ( ( currentColor = [edgeEnum nextObject]) != nil) {
        NSUInteger colorCount = [colors countForObject:currentColor];
        if ( colorCount <= 2 ) {
            continue;
        }
        CountedColor *container = [[CountedColor alloc] initWithColor:currentColor count:colorCount];
        [sortedEdgeColors addObject:container];
    }
    
    return [sortedEdgeColors sortedArrayUsingSelector:@selector(compare:)];
}

- (UIColor*)determineBackgroundColorFromColors:(ColorSets*)colors
{
    CountedColor *proposedEdgeColor = nil;
    
    if ( [colors.sortedEdgeColors count] > 0 ) {
        proposedEdgeColor = [colors.sortedEdgeColors objectAtIndex:0];
        
        if ( [proposedEdgeColor.color isBlackOrWhite] ) {
            for (NSInteger i = 1; i < [colors.sortedEdgeColors count]; i++) {
                CountedColor *nextProposedColor = [colors.sortedEdgeColors objectAtIndex:i];
                
                if (((double)nextProposedColor.count / (double)proposedEdgeColor.count) > 0.3 ) {
                    if ( ![nextProposedColor.color isBlackOrWhite] ) {
                        proposedEdgeColor = nextProposedColor;
                        break;
                    }
                } else {
                    break;
                }
            }
        }
    }
    
    return proposedEdgeColor.color;
}

- (void)determineColorsFromColors:(NSArray*)colors
{
    
    for (CountedColor *container in colors) {
        UIColor *color = container.color;
        if ( self.primaryColor == nil ) {
            if ( [color isContrastingColor: self.backgroundColor] ) {
                self.primaryColor = color;
            }
        } else if ( self.secondaryColor == nil ) {
            if ( ![self.primaryColor isDistinct:color] || ![color isContrastingColor:self.backgroundColor] ) {
                continue;
            }
            self.secondaryColor = color;
        } else if ( self.detailColor == nil ) {
            if ( ![self.secondaryColor isDistinct:color] || ![self.primaryColor isDistinct:color] || ![color isContrastingColor:self.backgroundColor] ) {
                continue;
            }
            self.detailColor = color;
            break; // got all colors; get out of loop
        }
    }
}

@end

@implementation CountedColor

- (id)initWithColor:(UIColor*)color count:(NSUInteger)count
{
	self = [super init];
	
	if ( self ){
		self.color = color;
		self.count = count;
	}
	
	return self;
}

- (NSComparisonResult)compare:(CountedColor*)object
{
	if ( [object isKindOfClass:[CountedColor class]] ) {
		if ( self.count < object.count ) {
			return NSOrderedDescending;
		} else if ( self.count == object.count ) {
			return NSOrderedSame;
		}
	}
    
	return NSOrderedAscending;
}

@end

@implementation ColorSets

@end


