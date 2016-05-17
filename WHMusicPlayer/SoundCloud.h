//
//  SoundCloud.h
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 4/25/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol SoundCloudPlayerDelegate;

@class AVPlayer, AVPlayerItem;
@interface SoundCloud : NSObject
{
    NSDictionary *currentTrack;
    AVPlayerItem *item;
}

@property (strong, nonatomic) AVPlayer *avPlayer;
@property (nonatomic, getter=isPlaying) BOOL playing;
@property (weak) NSObject<SoundCloudPlayerDelegate> *delegate;


/**
 *  Init a singleton of the location manager.
 */
+ (instancetype)player;

/**
 *  Set the player's current play status.
 */
- (void)_setIsPlaying:(BOOL)isPlaying;

/**
 *  Load and play a track with a given track dictionary.
 *
 *  Track should be the exact track JSON returned from SoundCloud containing
 *  the stream_url key.
 */
- (void)_loadAndPlayTrack:(NSDictionary *)track;

/**
 *  Play a raw audio file given a URL.
 */
- (void)_loadAndPlayURLString:(NSString *)url;

/**
 *  Get the JSON object of the current track.
 */
- (NSDictionary *)_getCurrentTrack;


/** Returns the current approximate playback position of the current track. */
- (NSNumber *)currentPlaybackPosition;

/** Returns the length of the current track. */
- (NSNumber *)currentTrackDuration;




+ (void)getUser_userInfo:(NSDictionary *)dict success:(void (^)(NSDictionary *responseObject))succcessBlock fail:(void (^)(BOOL finished))failBlock;

/**
 *  Get more track information using a SoundCloud track ID.
 */
+ (void)getTrack_userInfo:(NSDictionary *)dict success:(void (^)(NSDictionary *responseObject))succcessBlock fail:(void (^)(BOOL finished))failBlock;

/**
 *  Use with _loadAndPlayURLString in callback.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery userInfo:(NSDictionary *)dict callback:(void (^)(NSArray *results))block;

@end


@protocol SoundCloudPlayerDelegate <NSObject>
@optional
- (void)soundCloud:(SoundCloud *)soundcloud didChangePlaybackStatus:(BOOL)playing;
- (void)soundCloud:(SoundCloud *)soundcloud didSeekToOffset:(NSTimeInterval)offset;
- (void)soundCloud:(SoundCloud *)soundcloud didChangeToTrack:(NSDictionary *)trackMetadata;
- (void)soundCloud:(SoundCloud *)soundcloud didFailToPlayTrack:(NSURL *)trackUri;
@end