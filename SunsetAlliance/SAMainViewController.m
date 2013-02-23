//
//  SAMainViewController.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/5/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SAMainViewController.h"
#import "HysteriaPlayer.h"
#import "AFJSONRequestOperation.h"
#import "Reachability.h"
#import "MBProgressHUD.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GAI.h"


typedef void (^ Result)(id JSON);
typedef void (^ Callback)(NSString *category, NSString *name, NSString *label);
typedef void (^ HUDWork)(Callback block);

#define CATEGORY_UI_ACTION @"ui_action"
#define ACTION_BUTTON @"button"
#define ACTION_GESTURE @"gesture"
#define ACTION_REMOTE @"remote"
#define BUTTON_INFO @"info"
#define BUTTON_TOGGLE @"toggle"
#define BUTTON_PLAY @"play"
#define BUTTON_PAUSE @"pause"
#define BUTTON_NEXT @"next"
#define BUTTON_PREVIOUS @"previous"
#define BUTTON_STOP @"stop"
#define GESTURE_SWIPE_LEFT @"swipe_left"
#define GESTURE_SWIPE_RIGHT @"swipe_right"
#define GESTURE_LONG_PRESS @"long_press"
#define GESTURE_TAP @"tap"
#define GESTURE_TAP_WHILE_WORKING @"tap_while_working"

#define CATEGORY_HUD @"hud"
#define NAME_REACHABILITY @"reachability"
#define NAME_METADATA @"metadata"
#define LABEL_FAIL @"fail"
#define LABEL_SUCCESS @"success"

#define CATEGORY_PLAYER @"player"
#define ACTION_PLAYLIST @"playlist"
#define LABEL_READY @"PlayerReadyToPlay"
#define LABEL_ITEM_READY @"ItemReadyToPlay"
#define LABEL_END @"PlayerDidReachEnd"
#define LABEL_RATE_CHANGE @"PlayerRateChanged"
#define ACTION_PLAYING @"CurrentItemChanged"

@interface SAMainViewController ()
{
    HysteriaPlayer *player;
    
    NSArray *songs;
    
    __block NSMutableArray *urls;
    
    BOOL isWorking;
    
    NSDictionary *metadata;
    
    NSUInteger selectedIndex;
    
    id<GAITracker> tracker;
}

@end

@implementation SAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tracker = [GAI sharedInstance].defaultTracker;
    
    self.trackedViewName = @"Play Screen";
    
    self.view.backgroundColor = [UIColor colorWithRed:0.18039215686275 green:0.55686274509804 blue:0.54901960784314 alpha:1.0];
    
    [self initWithDefaults];
    
    player = [[HysteriaPlayer sharedInstance]
              initWithHandlerPlayerReadyToPlay:^{
                  NSLog(@"PlayerReadyToPlay");
                  [tracker sendEventWithCategory:CATEGORY_PLAYER withAction:ACTION_PLAYLIST withLabel:LABEL_READY withValue:nil];
              }
              PlayerRateChanged:^{
                  NSLog(@"PlayerRateChanged");
                  [tracker sendEventWithCategory:CATEGORY_PLAYER withAction:ACTION_PLAYLIST withLabel:LABEL_RATE_CHANGE withValue:nil];
              }
              CurrentItemChanged:^(AVPlayerItem *newItem, NSInteger index) {
                  NSLog(@"CurrentItemChanged - %d", index);
                  [self handleTrackChangeToIndex:index];
              }
              ItemReadyToPlay:^{
                  NSLog(@"ItemReadyToPlay");
                  [tracker sendEventWithCategory:CATEGORY_PLAYER withAction:ACTION_PLAYLIST withLabel:LABEL_ITEM_READY withValue:nil];
              }
              PlayerFailed:^{
                  NSLog(@"PlayerFailed");
                  [tracker sendEventWithCategory:CATEGORY_PLAYER withAction:ACTION_PLAYLIST withLabel:LABEL_FAIL withValue:nil];
              }
              PlayerDidReachEnd:^{
                  UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mix tape is over" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                  [alert show];
                  [tracker sendEventWithCategory:CATEGORY_PLAYER withAction:ACTION_PLAYLIST withLabel:LABEL_END withValue:nil];
              }];
    // explicitly stop so that music does not play immediately upon loading
    [player setPAUSE_REASON_ForcePause:YES];
    
    // async load music
    [self runBlock:^(Callback callback){
        [self loadSongsWithUICallback:callback andResultCallback:^(id JSON) {
            [self handleResults:JSON];
        }];
    }];
    
    // basic animation
    self.tapeImage.animationImages = @[
                                       [UIImage imageNamed:@"tape_2@2x.png"],
                                       [UIImage imageNamed:@"tape_3@2x.png"],
                                       [UIImage imageNamed:@"tape_4@2x.png"],
                                       [UIImage imageNamed:@"tape_1@2x.png"]];
    self.tapeImage.animationDuration = 1.0;
    self.tapeImage.animationRepeatCount = 0;
    
    // TODO is this necessary anymore?
    [self syncButtons];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                [self togglePausePlay];
                [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_REMOTE withLabel:BUTTON_TOGGLE withValue:nil];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [self pause];
                [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_REMOTE withLabel:BUTTON_PAUSE withValue:nil];
                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [self play];
                [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_REMOTE withLabel:BUTTON_PLAY withValue:nil];
                break;
            }
            case UIEventSubtypeRemoteControlNextTrack: {
                [player playNext];
                [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_REMOTE withLabel:BUTTON_NEXT withValue:nil];
                break;
            }
            case UIEventSubtypeRemoteControlPreviousTrack: {
                [player playPrevious];
                [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_REMOTE withLabel:BUTTON_PREVIOUS withValue:nil];
                break;
            }
            case UIEventSubtypeRemoteControlStop: {
                [self pause];
                [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_REMOTE withLabel:BUTTON_STOP withValue:nil];
                break;
            }
            default:
                break;
        }
    }
}


- (void)initWithDefaults
{
    isWorking = NO;
    metadata = nil;
    selectedIndex = 0;
    
    // TODO temp font handling
    self.titleLabel.text = @"";
    self.titleLabel.font = [UIFont fontWithName:@"KBSoThinterestingBold" size:30.0];
    self.titleLabel.numberOfLines = 1;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self.titleLabel sizeToFit];
    
    self.bandLabel.text = @"";
    self.bandLabel.font = [UIFont fontWithName:@"KBSoThinterestingBold" size:20.0];
    [self.bandLabel sizeToFit];
}

//{
//    "album": "In Lieu of the Flu",
//    "grouping": "Sunset Alliance Mix Tape Volume I",
//    "year": "2013",
//    "tracks":[{
//        "artist": "Before Braille",
//        "title": "The Spanish Dagger",
//        "album": "The Rumor",
//        "year": "2002",
//        "duration": 250,
//        "url": "https://phonebooth-varies.s3.amazonaws.com/book/media/mixtape_01/01_Before_Braille_The_Spanish_Dagger.m4a"
//    }]
//}
- (void)handleResults:(id) JSON
{
    if (nil != JSON && [JSON isKindOfClass:[NSDictionary class]]) {
        // save off
        metadata = JSON;
        
        [player setupWithGetterBlock:^NSString *(NSUInteger index) {
            NSDictionary *info = [self trackInfoForIndex:index];
            return info[@"url"];
            //                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            //                formatter.dateFormat = @"e";
            //                NSString *dayOfWeek = [formatter stringFromDate:[NSDate date]];
            //                NSLog(@"%@", dayOfWeek);
            //                return urls[[dayOfWeek intValue]];
        } ItemsCount:[metadata[@"tracks"] count]];
        
        [player fetchAndPlayPlayerItem:0];
        [player setPLAYMODE_Repeat:YES];
    }
}

- (void)handleTrackChangeToIndex:(NSUInteger)index
{
    selectedIndex = index;
    NSDictionary *info = [self trackInfoForIndex:index];
    if (info != nil) {
        NSString *artist = info[@"artist"];
        NSString *songTitle = info[@"title"];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.titleLabel.text = songTitle;
            self.bandLabel.text = artist;
        });
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = [self trackMPInfoForIndex:index];
        NSLog(@"index -> %d; info -> %@", selectedIndex, info);
        [tracker sendEventWithCategory:CATEGORY_PLAYER withAction:ACTION_PLAYING withLabel:[NSString stringWithFormat:@"%@ (%@)", songTitle, artist] withValue:nil];
    }
}

- (NSDictionary*)trackInfoForIndex:(NSUInteger)index
{
    return metadata[@"tracks"][index];
}

- (NSDictionary*)trackMPInfoForIndex:(NSUInteger)index
{
    NSDictionary *info = [self trackInfoForIndex:index];
    if (info != nil) {
        return @{
                 MPMediaItemPropertyTitle: info[@"title"],
                 MPMediaItemPropertyAlbumArtist: info[@"artist"],
                 MPMediaItemPropertyArtist: info[@"artist"],
                 MPMediaItemPropertyAlbumTitle: metadata[@"album"],
                 MPMediaItemPropertyAlbumTrackCount: [NSNumber numberWithUnsignedInteger:[metadata count]],
                 MPMediaItemPropertyAlbumTrackNumber: [NSNumber numberWithUnsignedInteger:index + 1],
                 MPMediaItemPropertyPlaybackDuration: info[@"duration"],
                 MPNowPlayingInfoPropertyPlaybackRate: [NSNumber numberWithDouble:1.0],
                 MPNowPlayingInfoPropertyPlaybackQueueIndex: [NSNumber numberWithUnsignedInteger: index],
                 MPNowPlayingInfoPropertyPlaybackQueueCount: [NSNumber numberWithUnsignedInteger:[metadata count]]
                 };
    } else {
        return @{};
    }
}

- (void)runBlock:(HUDWork)work
{
    NSDate *startTime = [NSDate date];
    isWorking = YES;
    MBProgressHUD *progress = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    progress.dimBackground = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        work(^(NSString *category, NSString *name, NSString *label){
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                isWorking = NO;
                // track overall time user has to wait for work to run
                [tracker sendTimingWithCategory:category withValue:[startTime timeIntervalSinceNow] withName:name withLabel:label];
            });
        });
        
    });
}

- (void)loadSongsWithUICallback:(Callback)callback andResultCallback:(Result)result
{
    
    Reachability *reachability = [Reachability reachabilityWithHostname:@"itunes.apple.com"];
    
    reachability.reachableBlock = ^(Reachability *reach)
    {
        [player removeAllItems];
        NSString *urlStr =  @"https://phonebooth-varies.s3.amazonaws.com/book/media/mixtape_01/metadata.json";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        urls = [NSMutableArray array];
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"success");
            result(JSON);
            callback(CATEGORY_HUD, NAME_METADATA, LABEL_SUCCESS);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"failed");
            callback(CATEGORY_HUD, NAME_METADATA, LABEL_FAIL);
        }];
        
        [operation start];
    };
    
    reachability.unreachableBlock = ^(Reachability *reach)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.labelText = @"No Internet?";
            hud.detailsLabelText = @"Try again later";
            hud.mode = MBProgressHUDModeText;
            hud.dimBackground = YES;
        });
        callback(CATEGORY_HUD, NAME_REACHABILITY, LABEL_FAIL);
    };
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadSongs:)
//                                                 name:kReachabilityChangedNotification
//                                               object:block];

    [reachability startNotifier];
}

- (void)syncButtons
{
    
    switch ([player pauseReason]) {
        case HysteriaPauseReasonUnknown:
            break;
        case HysteriaPauseReasonForce:
            [self showPause];
            [self.tapeImage stopAnimating];
            break;
        case HysteriaPauseReasonPlaying:
            [self hidePause];
            [self.tapeImage startAnimating];
            break;
        default:
            break;
    }
}

- (void)showPause
{
    MBProgressHUD *pauseHUD = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    pauseHUD.labelText = @"paused";
    pauseHUD.mode = MBProgressHUDModeText;
    pauseHUD.dimBackground = YES;
    NSLog(@"%lu", (unsigned long)[[MBProgressHUD allHUDsForView:self.view]count]);
}

- (void)hidePause
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
                 
-(void)play
{
    [player setPAUSE_REASON_ForcePause:NO];
    [player play];
    NSLog(@"play");
    [self syncButtons];
}

-(void)pause
{
    [player setPAUSE_REASON_ForcePause:YES];
    [player pause];
    NSLog(@"pause");
    [self syncButtons];
}

- (void)togglePausePlay
{
    if ([player isPlaying]) {
        [self pause];
    } else {
        [self play];
    }
}

#pragma gesture handling

- (IBAction)handleTap:(id)sender {
    if (!isWorking) {
        [self togglePausePlay];
        NSLog(GESTURE_TAP);
        [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_GESTURE withLabel:GESTURE_TAP withValue:nil];
    } else {
        NSLog(@"working, no handle tap");
        [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_GESTURE withLabel:GESTURE_TAP_WHILE_WORKING withValue:nil];
    }
}

- (IBAction)handleLongPress:(id)sender {
    [self performSegueWithIdentifier:@"showAlternate" sender:self];
    NSLog(GESTURE_LONG_PRESS);
    [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_GESTURE withLabel:GESTURE_LONG_PRESS withValue:nil];
}

- (IBAction)handleSwipeRight:(id)sender {
    [player playPrevious];
    NSLog(GESTURE_SWIPE_RIGHT);
    [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_GESTURE withLabel:GESTURE_SWIPE_RIGHT withValue:nil];
}

- (IBAction)handleSwipeLeft:(id)sender {
    [player playNext];
    NSLog(GESTURE_SWIPE_LEFT);
    [tracker sendEventWithCategory:CATEGORY_UI_ACTION withAction:ACTION_GESTURE withLabel:GESTURE_SWIPE_LEFT withValue:nil];
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(SAFlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        SAFlipsideViewController *viewController = [segue destinationViewController];
        viewController.delegate = self;
        
        NSDictionary *info = [self trackInfoForIndex:selectedIndex];
        viewController.artist = info[@"artist"];
        viewController.songTitle = info[@"title"];
        viewController.album = info[@"album"];
        viewController.year = info[@"year"];
        viewController.artwork1 = info[@"artwork"][@"1"];
        viewController.artwork2 = info[@"artwork"][@"2"];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
