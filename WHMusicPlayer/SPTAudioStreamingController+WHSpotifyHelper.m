//
//  SPTAudioStreamingController+WHSpotifyHelper.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 1/20/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "SPTAudioStreamingController+WHSpotifyHelper.h"

@implementation SPTAudioStreamingController (WHSpotifyHelper)

- (void)initControlCenterWithTarget:(id)target playPauseAction:(SEL)playPauseAction rewindAction:(SEL)rewindAction fastForwardAction:(SEL)fastForwardAction
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTarget:target action:playPauseAction];
    [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTarget:target action:playPauseAction];
    [[MPRemoteCommandCenter sharedCommandCenter].previousTrackCommand addTarget:target action:rewindAction];
    [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTarget:target action:fastForwardAction];
}


- (void)setNowPlayingInfoWithCurrentTrack:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(double)duration albumArt:(MPMediaItemArtwork *)albumArt
{
    NSMutableDictionary *info = [NSMutableDictionary
                                 dictionaryWithDictionary:@{
                                                            MPMediaItemPropertyTitle: title,
                                                            MPMediaItemPropertyArtist: artist,
                                                            MPMediaItemPropertyAlbumTitle: album,
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
    [nowPlayingInfo setObject:[NSNumber numberWithDouble:self.currentPlaybackPosition] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
}


- (void)searchAndPlayWithQuery:(NSString *)query
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [SPTSearch performSearchWithQuery:query queryType:SPTQueryTypeTrack accessToken:auth.session.accessToken callback:^(NSError *error, SPTListPage *object) {
        if (object.items.count > 1)
            [self playURIs:object.items fromIndex:0 callback:nil];
    }];
}


- (void)confirmTrackIsPlaying:(void (^)(void))isPlaying isNotPlaying:(void (^)(void))isNotPlaying
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        if (self.isPlaying)
        {
            if (isPlaying) isPlaying();
        }
        else
        {
            if (isNotPlaying) isNotPlaying();
            
            [self setIsPlaying:YES callback:nil];
            [self confirmTrackIsPlaying:^{
                if (isPlaying) isPlaying();
            } isNotPlaying:^{
                if (isNotPlaying) isNotPlaying();
            }];
        }
    });
    
    // TODO: might have to check if source of pause was user or buffer
}

@end
