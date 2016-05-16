//
//  SpotifyTrackTableViewCell.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/3/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "TrackTableViewCell.h"
#import "PlaybackQueue.h"
#import <MBProgressHUD.h>


@implementation TrackTableViewCell

- (void)addLongTapToQueueForTrack:(id)theTrack
{
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapToQueue:)];
    [self addGestureRecognizer:longPressGesture];
    self.track = theTrack;
}



#pragma mark - Private

- (void)longTapToQueue:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [[PlaybackQueue manager] _playLater:@[self.track]];
        [self showAddedToQueue];
    }
}


- (void)showAddedToQueue
{
    UIViewController *vc = ((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController).topViewController;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Added to queue";
    
    [hud hide:YES afterDelay:1.f];
}

@end
