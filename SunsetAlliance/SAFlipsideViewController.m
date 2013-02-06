//
//  SAFlipsideViewController.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SAFlipsideViewController.h"

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
	// Do any additional setup after loading the view, typically from a nib.
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

@end
