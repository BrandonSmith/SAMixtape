//
//  SARemoteImageView.m
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/18/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import "SARemoteImageView.h"

@interface SARemoteImageView()

/*
 * The URL of the image.
 */
@property (nonatomic, readwrite, copy) NSString *url;

/*
 * Activity indicator to be shown while image is downloaded
 */
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *activityIndicator;

/*
 * Initialize control
 */
- (void)initializeControl;

@end

@implementation SARemoteImageView

@synthesize url = url_;
@synthesize activityIndicator = activityIndicator_;

#pragma mark - Instance initialization

/*
 * Initialize control
 */
- (void)initializeControl {
    
    if (self) {
        
        activityIndicator_ = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator_ setHidesWhenStopped:YES];
        [activityIndicator_ setCenter:CGPointMake(CGRectGetMidX([self bounds]), CGRectGetMidY([self bounds]))];
        [activityIndicator_ setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
        [self addSubview:activityIndicator_];
    }
}

/*
 * Designated initalizer
 */
- (id)init {
    
    if (self = [super init]) {
        
        [self initializeControl];
    }
    
    return self;
}

/*
 * Returns an object initialized from data in a given unarchiver. (required)
 */
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    if (self = [super initWithCoder:aDecoder]) {
        
        [self initializeControl];
    }
    
    return self;
}

/*
 * Initializes and returns a newly allocated view object with the specified frame rectangle.
 */
- (id)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        [self initializeControl];
    }
    
    return self;
}

/*
 * Returns an image view initialized with the specified image.
 */
- (id)initWithImage:(UIImage *)image {
    
    if (self = [super initWithImage:image]) {
        
        [self initializeControl];
    }
    
    return self;
}

/*
 * Returns an image view initialized with the specified regular and highlighted images.
 */
- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    
    if (self = [super initWithImage:image highlightedImage:highlightedImage]) {
        
        [self initializeControl];
    }
    
    return self;
}

#pragma mark - Visuals

/*
 * Downloads and displays the image from the given URL.
 */
- (void)displayImageFromURL:(NSString *)url
          completionHandler:(void(^)(NSError *error))completionBlock {
    
    if ([url length] > 0 && ![url_ isEqualToString:url]) {
        
        [self setImage:nil];
        url_ = [url copy];
        [activityIndicator_ startAnimating];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
            UIImage *image = [UIImage imageWithData:imageData];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSError *error = nil;
                [activityIndicator_ stopAnimating];
                
                if (image != nil) {
                    
                    [self setImage:image];
                    
                } else {
                    
                    error = [NSError errorWithDomain:@"remoteimageview"
                                                code:-1
                                            userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Cannot download image from '%@'", url_] }];
                }
                
                completionBlock(error);
            });
        });
    }
}

@end
