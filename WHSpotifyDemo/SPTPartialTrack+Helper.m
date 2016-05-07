//
//  SPTTrack+Helper.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 5/6/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SPTPartialTrack+Helper.h"
#import "PlaybackQueue.h"


@implementation SPTPartialTrack (Helper)

- (BOOL)isPlaying
{
    if (![PlaybackQueue manager].currentTrack || !self) return NO;
    return [[PlaybackQueue manager].currentTrack isEqual:self];
}

@end
