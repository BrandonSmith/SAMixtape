//
//  SAMainViewController.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SAFlipsideViewController.h"
#import "GAITrackedViewController.h"

@interface SAMainViewController : GAITrackedViewController <SAFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *tapeImage;
@property (strong, nonatomic) IBOutlet UIView *parentView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bandLabel;

- (IBAction)handleTap:(id)sender;
- (IBAction)handleLongPress:(id)sender;
- (IBAction)handleSwipeRight:(id)sender;
- (IBAction)handleSwipeLeft:(id)sender;

@end
