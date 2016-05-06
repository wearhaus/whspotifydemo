//
//  PlaybackQueue.h
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 5/6/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "kMusicServices.h"


@class SPTAudioStreamingController;
@interface PlaybackQueue : NSObject

@property (strong, nonatomic, getter=getPreviousSongs, getter=getPreviousTracks) NSArray *history;
@property (strong, nonatomic, getter=getUpNext, getter=getNextSongs, getter=getNextTracks) NSArray *queue;
@property (strong, nonatomic, getter=getNowPlaying, getter=getCurrentSong, getter=getSong, getter=getTrack) NSDictionary *currentTrack;

@property (assign, nonatomic) SPTAudioStreamingController *spotifyPlayer;
@property (nonatomic) MusicOrigin lastMusicOrigin;

/**
 *  Init a singleton of the queue manager.
 */
+ (instancetype)manager;

/**
 *  Instantly load and play a track.
 */
- (void)_play:(NSArray *)tracks;
- (void)_togglePlayPause;
/**
 *  Adds tracks to a queue
 */
- (void)_playNext:(NSArray *)tracks;
/**
 *  Load next track from queue.
 */
- (void)_next;
/**
 *  Load a track from the history queue, move current song to queue.
 */
- (void)_previous;

@end
