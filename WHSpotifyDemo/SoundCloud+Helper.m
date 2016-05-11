//
//  SoundCloud+Helper.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 4/27/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SoundCloud+Helper.h"
#import "AVPlayerItem+Helper.h"
#import <AVFoundation/AVPlayer.h>


@implementation SoundCloud (Helper)

- (void)setNowPlayingInfoWithCurrentTrack:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(double)duration albumArt:(MPMediaItemArtwork *)albumArt
{
    NSMutableDictionary *info = [NSMutableDictionary
                                 dictionaryWithDictionary:@{
                                                            MPMediaItemPropertyTitle: title ? title : @"",
                                                            MPMediaItemPropertyArtist: artist ? artist : @"",
                                                            MPMediaItemPropertyAlbumTitle: album ? album : @"from Wearhaus (via SoundCloud)",
                                                            MPMediaItemPropertyPlaybackDuration: [NSNumber numberWithDouble:duration]
                                                            }];
    
    if (albumArt != nil) {
        [info setValue:albumArt forKey:MPMediaItemPropertyArtwork];
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:info];
}


- (void)updateCurrentPlaybackPosition
{
    NSMutableDictionary *nowPlayingInfo = [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo mutableCopy];
    
    [nowPlayingInfo setObject:[self.avPlayer.currentItem _seconds] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}

@end
