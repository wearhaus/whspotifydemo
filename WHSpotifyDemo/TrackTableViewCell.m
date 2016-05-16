//
//  SpotifyTrackTableViewCell.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/3/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "TrackTableViewCell.h"
#import "PlaybackQueue.h"


@implementation TrackTableViewCell

- (void)addLongTapToQueueForTrack:(id)theTrack
{
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapToQueue:)];
    [self addGestureRecognizer:longPressGesture];
    self.track = theTrack;
}


- (void)longTapToQueue:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        [[PlaybackQueue manager] _playLater:@[self.track]];
    }
}

@end
