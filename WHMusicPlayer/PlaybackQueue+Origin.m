//
//  PlaybackQueue+Origin.m
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 5/6/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "PlaybackQueue+Origin.h"
#import "SoundCloud.h"
#import <Spotify/SPTAudioStreamingController.h>


@implementation PlaybackQueue (Origin)

#pragma mark - Public

- (void)changeLastMusicOrigin:(MusicOrigin)lastMusicOrigin
{
    BOOL didChangeOrigin = lastMusicOrigin != self.lastMusicOrigin;
    self.lastMusicOrigin = lastMusicOrigin;
    
    if (didChangeOrigin) [self didChangeMusicOrigin];
}


- (void)forActiveMusicPlayerSpotify:(void (^)(void))spotifyBlock soundCloud:(void (^)(void))soundCloudBlock
{
    switch (self.lastMusicOrigin)
    {
        case MusicOriginSpotify:
        {
            if (spotifyBlock) spotifyBlock();
            break;
        }
            
        case MusicOriginSoundCloud:
        {
            if (soundCloudBlock) soundCloudBlock();
            break;
        }
    }
}



#pragma mark - Private


- (void)didChangeMusicOrigin
{
    [self forActiveMusicPlayerSpotify:^
     {
         [[SoundCloud player] _setIsPlaying:NO];
         
     } soundCloud:^
     {
         [self.spotifyPlayer setIsPlaying:NO callback:nil];
     }];
}

@end
