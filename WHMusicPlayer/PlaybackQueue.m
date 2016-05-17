//
//  PlaybackQueue.m
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 5/6/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "PlaybackQueue.h"
#import "PlaybackQueue+Origin.h"
#import "SoundCloud.h"
#import "SoundCloud+Helper.h"
#import <Spotify/SPTTrack.h>
#import <Spotify/SPTAudioStreamingController.h>
#import "SPTAudioStreamingController+WHSpotifyHelper.h"


@implementation PlaybackQueue

#pragma mark - Public
#pragma mark Player

+ (instancetype)manager
{
    static PlaybackQueue *_player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player = [[self alloc] _initManager];
    });
    
    return _player;
}


- (instancetype)_initManager
{
    self = [super init];
    {
        self.history = [NSArray array];
        self.queue = [NSArray array];
    }
    return self;
}

- (void)_play:(NSArray *)tracks
{
    [self _playNext:tracks];
    [self _next];
}


- (void)playNow:(id)track
{
    [self updateOriginWithTrack:track];
    [self forActiveMusicPlayerSpotify:^
     {
         SPTAuth *auth = [SPTAuth defaultInstance];
         SPTTrack *spotifyTrack = (SPTTrack *)track;
         self.currentTrack = spotifyTrack;
         
         [SPTTrack trackWithURI:spotifyTrack.uri session:auth.session callback:^(NSError *error, id object) {
             NSArray *tracks = @[spotifyTrack.playableUri];
             [self.spotifyPlayer playURIs:tracks fromIndex:0 callback:nil];
             [self.spotifyPlayer confirmTrackIsPlaying:nil isNotPlaying:^{
                 NSLog(@"buffering track...");
             }];
         }];
         
     } soundCloud:^
     {
         self.currentTrack = track;
         [[SoundCloud player] _loadAndPlayTrack:self.currentTrack];
     }];
}


- (void)_togglePlayPause
{
    [self forActiveMusicPlayerSpotify:^
     {
         [self.spotifyPlayer setIsPlaying:!self.spotifyPlayer.isPlaying callback:nil];
         [self.spotifyPlayer updateCurrentPlaybackPosition];
         
     } soundCloud:^
     {
         [[SoundCloud player] _setIsPlaying:![SoundCloud player].isPlaying];
         [[SoundCloud player] updateCurrentPlaybackPosition];
     }];
}


- (void)_playNext:(NSArray *)tracks
{
    [self queue_queueTracks:tracks];
}


- (void)_playLater:(NSArray *)tracks
{
    [self queue_addTracks:tracks];
}


- (void)_next
{
    if (!self.queue.count) return;
    
    [self history_addTrack:self.currentTrack];
    [self playNow:[self queue_popTrack]];
}


- (void)_previous
{
    if (!self.history.count) return;
    
    [self _playNext:@[self.getTrack]];
    [self playNow:[self history_popTrack]];
}



#pragma mark Helper

- (void)history_addTrack:(NSDictionary *)track
{
    if (!track) return;
    
    NSMutableArray *history = [NSMutableArray arrayWithArray:self.history];
    [history addObject:track];
    
    self.history = [NSArray arrayWithArray:history];
}


- (NSDictionary *)history_popTrack
{
    NSMutableArray *history = [NSMutableArray arrayWithArray:self.history];
    NSDictionary *track = [history lastObject];
    
    [history removeLastObject];
    self.history = [NSArray arrayWithArray:history];
    
    return track;
}


- (void)queue_addTracks:(NSArray<NSDictionary *> *)tracks
{
    if (!tracks || !tracks.count) return;
    
    NSMutableArray *queue = [NSMutableArray arrayWithArray:self.queue];
    [queue insertObjects:tracks atIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    self.queue = [NSArray arrayWithArray:queue];
}


- (void)queue_queueTracks:(NSArray<NSDictionary *> *)tracks
{
    if (!tracks || !tracks.count) return;
    
    NSMutableArray *queue = [NSMutableArray arrayWithArray:self.queue];
    [queue addObjectsFromArray:tracks];
    
    self.queue = [NSArray arrayWithArray:queue];
}


/**
 *  Removes a track from the next queue and returns that track.
 */
- (NSDictionary *)queue_popTrack
{
    NSMutableArray *queue = [NSMutableArray arrayWithArray:self.queue];
    NSDictionary *track = [queue lastObject];
    
    [queue removeLastObject];
    self.queue = [NSArray arrayWithArray:queue];
    
    return track;
}


- (void)updateOriginWithTrack:(id)track
{
    if ([track isKindOfClass:[SPTPartialTrack class]])
        [self changeLastMusicOrigin:MusicOriginSpotify];
        
    if ([track isKindOfClass:[NSDictionary class]])
        [self changeLastMusicOrigin:MusicOriginSoundCloud];
}


- (NSArray *)removeDuplicates:(NSArray *)arr
{
    return [NSOrderedSet orderedSetWithArray:arr].array;
}


- (id)nextTrack
{
    return [self.queue lastObject];
}

@end
