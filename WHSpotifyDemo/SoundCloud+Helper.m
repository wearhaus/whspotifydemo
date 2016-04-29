//
//  SoundCloud+Helper.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 4/27/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SoundCloud+Helper.h"
#import <AVFoundation/AVPlayer.h>


@implementation SoundCloud (Helper)

- (void)setNowPlayingInfoWithCurrentTrack:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(double)duration albumArt:(MPMediaItemArtwork *)albumArt
{
    NSMutableDictionary *info = [NSMutableDictionary
                                 dictionaryWithDictionary:@{
                                                            MPMediaItemPropertyTitle: title ? title : @"",
                                                            MPMediaItemPropertyArtist: artist ? artist : @"",
                                                            MPMediaItemPropertyAlbumTitle: album ? album : @"",
                                                            MPMediaItemPropertyPlaybackDuration: [NSNumber numberWithDouble:duration]
                                                            }];
    
    if (albumArt != nil) {
        [info setValue:albumArt forKey:MPMediaItemPropertyArtwork];
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}


- (void)updateCurrentPlaybackPosition
{
    NSNumber *seconds = [NSNumber numberWithDouble:self.avPlayer.currentTime.value/self.avPlayer.currentTime.timescale];
    NSMutableDictionary *nowPlayingInfo = [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo mutableCopy];
    
    [nowPlayingInfo setObject:seconds forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}

@end
