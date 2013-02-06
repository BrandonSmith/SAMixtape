//
//  SAMainViewController.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SAFlipsideViewController.h"

@interface SAMainViewController : UIViewController <SAFlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
