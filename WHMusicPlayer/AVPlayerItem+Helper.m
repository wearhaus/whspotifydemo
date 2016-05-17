//
//  AVPlayerItem+Helper.m
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 5/3/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "AVPlayerItem+Helper.h"

@implementation AVPlayerItem (Helper)

- (NSNumber *)_seconds
{
    return [NSNumber numberWithDouble:self.currentTime.value/self.currentTime.timescale];
}

@end
