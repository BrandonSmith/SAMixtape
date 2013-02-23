//
//  SARemoteImageView.h
//  SunsetAlliance
//
//  Created by Brandon Smith on 2/18/13.
//  Copyright (c) 2013 Sunset Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SARemoteImageView : UIImageView
/**
 * Downloads and displays the image from the given URL.
 *
 * @param url The URL from which the image will be downloaded.
 * @param completionHandler The block invoked when the image download finishes.
 */
- (void)displayImageFromURL:(NSString *)url
          completionHandler:(void(^)(NSError *error))completionBlock;
@end
