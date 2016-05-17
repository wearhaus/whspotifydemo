//
//  SPTAudioStreamingController+WHSpotifyHelper.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 1/20/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <Spotify/Spotify.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>


/**
 *  Helper methods to assist with adapting to a standard iOS ecosystem.
 */
@interface SPTAudioStreamingController (WHSpotifyHelper)

/**
 *  Initializes the control center to accept permissions to modify and sets the
 *  actions that run when the control center buttons are pressed.
 *
 *  This should be set as soon as the Spotify player object is created.
 */
- (void)initControlCenterWithTarget:(id)target playPauseAction:(SEL)playPauseAction rewindAction:(SEL)rewindAction fastForwardAction:(SEL)fastForwardAction;

/**
 *  Sets the control center now playing info and album art.
 */
- (void)setNowPlayingInfoWithCurrentTrack:(NSString *)title artist:(NSString *)artist album:(NSString *)album duration:(double)duration albumArt:(MPMediaItemArtwork *)albumArt;

/**
 *  Updates the playback position in the control center to mirror the one of the
 *  Spotify player.
 */
- (void)updateCurrentPlaybackPosition;

/**
 *  A quick temporary way to quickly play the first track of a given query.
 */
- (void)searchAndPlayWithQuery:(NSString *)query DEPRECATED_MSG_ATTRIBUTE("This method runs too slow and will be replaced to append to a queue.");

/**
 *  A quick confirmation whether or not a track is being played. This is to
 *  ensure a track is buffered enough for it to stream without permanantly
 *  pausing.
 */
- (void)confirmTrackIsPlaying:(void (^)(void))isPlaying isNotPlaying:(void (^)(void))isNotPlaying;

@end
