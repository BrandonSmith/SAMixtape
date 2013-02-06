//
//  SAFlipsideViewController.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SAFlipsideViewController;

@protocol SAFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(SAFlipsideViewController *)controller;
@end

@interface SAFlipsideViewController : UIViewController

@property (weak, nonatomic) id <SAFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
