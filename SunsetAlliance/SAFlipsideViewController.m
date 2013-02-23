//
//  SAFlipsideViewController.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SAFlipsideViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+Pixel.h"
#import "UIFont+FontAwesome.h"
#import "NSString+FontAwesome.h"

@interface SAFlipsideViewController ()

@end

@implementation SAFlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.trackedViewName = @"Info Screen";
    
//    [self.saLogo.image analyze];
//    
//    if (self.saLogo.image.backgroundColor != nil) {
//        self.view.backgroundColor = self.saLogo.backgroundColor;
//    }
//    
//    if (self.saLogo.image.primaryColor != nil) {
//        self.primary.textColor = self.saLogo.image.primaryColor;
//    }
//    
//    if (self.saLogo.image.secondaryColor != nil) {
//        self.secondary.textColor = self.saLogo.image.secondaryColor;
//    }
//    
//    if (self.saLogo.image.detailColor != nil) {
//        self.detail.textColor = self.saLogo.image.detailColor;
//    }
    

//    self.saLogo.layer.shadowOffset = CGSizeMake(0, 1.0);
//    self.saLogo.layer.shadowColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
//    self.saLogo.layer.shadowOpacity = 1.0;
    
//    self.detail.font = [UIFont fontWithName:kFontAwesomeFamilyName size:15.0];
//    self.detail.text = [NSString fontAwesomeIconStringForEnum:FAIconPause];
    
    self.primary.text = self.songTitle;
    [SAFlipsideViewController resizeLabel:self.primary];
    self.secondary.text = self.artist;
    [SAFlipsideViewController resizeLabel:self.secondary];
    self.detail.text = [NSString stringWithFormat:@"%@ (%@)", self.album, self.year];
//    [SAFlipsideViewController resizeLabel:self.detail];
    
    NSString *artwork = [SAFlipsideViewController isRetina] ? self.artwork2 : self.artwork1;
    
    [self.coverArt displayImageFromURL:artwork completionHandler:^(NSError *error) {
        if (error) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)handleTap:(id)sender {
    [self.delegate flipsideViewControllerDidFinish:self];
}

+ (void)resizeLabel:(UILabel*)label
{
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [label.text sizeWithFont:label.font constrainedToSize:maximumLabelSize lineBreakMode:label.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = label.frame;
    newFrame.size.height = expectedLabelSize.height;
    label.frame = newFrame;
}

+ (BOOL)isRetina
{
    return [[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2;
}

@end
