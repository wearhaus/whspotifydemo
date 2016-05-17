//
//  SoundCloud+Helper.h
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 4/27/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SoundCloud.h"
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>


@interface SoundCloud (Helper)

/**
 *  Sets the control center now playing info and album art.
 */
- (void)setNowPlayingInfoWithCurrentTrack:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(double)duration albumArt:(MPMediaItemArtwork *)albumArt;

/**
 *  Updates the playback position in the control center to mirror the one of the
 *  Spotify player.
 */
- (void)updateCurrentPlaybackPosition;

@end
