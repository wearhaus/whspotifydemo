//
//  SoundCloud.h
//  WHSpotifyDemo
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

- (void)_setIsPlaying:(BOOL)isPlaying;
- (void)_loadAndPlayTrack:(NSDictionary *)track;
- (void)_loadAndPlayURLString:(NSString *)url;
- (NSDictionary *)_getCurrentTrack;

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
@end