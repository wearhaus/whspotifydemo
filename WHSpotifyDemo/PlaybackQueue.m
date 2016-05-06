//
//  PlaybackQueue.m
//  WHSpotifyDemo
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
    [self history_addTrack:self.getTrack];
    [self forActiveMusicPlayerSpotify:^
    {
        SPTAuth *auth = [SPTAuth defaultInstance];
        SPTTrack *track = (SPTTrack *)[tracks firstObject];
        
        [SPTTrack trackWithURI:track.uri session:auth.session callback:^(NSError *error, id object) {
            NSArray *tracks = @[track.playableUri];
            [self.spotifyPlayer playURIs:tracks fromIndex:0 callback:nil];
            [self.spotifyPlayer confirmTrackIsPlaying:nil isNotPlaying:^{
                NSLog(@"buffering track...");
            }];
        }];
        
    } soundCloud:^
    {
        [self queue_addTracks:tracks];
        self.currentTrack = [self queue_popTrack];
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
    
}


- (void)_next
{
    [self forActiveMusicPlayerSpotify:^
    {
       [self.spotifyPlayer skipNext:nil];
        
    } soundCloud:^
    {
        [self history_addTrack:self.getTrack];
        self.currentTrack = [self queue_popTrack];
        [[SoundCloud player] _loadAndPlayTrack:self.getTrack];
    }];
}


- (void)_previous
{
    [self forActiveMusicPlayerSpotify:^
    {
        [self.spotifyPlayer skipPrevious:nil];
        
    } soundCloud:^
    {
        [self queue_addTracks:@[self.getTrack]];
        self.currentTrack = [self history_popTrack];
        [[SoundCloud player] _loadAndPlayTrack:self.getTrack];
        
    }];
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
    return track;
}


- (void)queue_addTracks:(NSArray<NSDictionary *> *)tracks
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
    return track;
}

@end
