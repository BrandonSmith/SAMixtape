//
//  SAFlipsideViewController.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SARemoteImageView.h"
#import "GAITrackedViewController.h"

@class SAFlipsideViewController;

@protocol SAFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(SAFlipsideViewController *)controller;
@end

@interface SAFlipsideViewController : GAITrackedViewController

@property (weak, nonatomic) id <SAFlipsideViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *saLogo;
@property (weak, nonatomic) IBOutlet UILabel *primary;
@property (weak, nonatomic) IBOutlet UILabel *secondary;
@property (weak, nonatomic) IBOutlet UILabel *detail;
@property (weak, nonatomic) IBOutlet SARemoteImageView *coverArt;

@property (strong, nonatomic) NSString *songTitle;
@property (strong, nonatomic) NSString *artist;
@property (strong, nonatomic) NSString *album;
@property (strong, nonatomic) NSString *year;
@property (strong, nonatomic) NSString *artwork1;
@property (strong, nonatomic) NSString *artwork2;

- (IBAction)done:(id)sender;
- (IBAction)handleTap:(id)sender;

@end
