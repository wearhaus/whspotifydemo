//
//  TabBarViewController.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "TabBarViewController.h"
#import "SpotifyConfig.h"
#import "NowPlayingBarView.h"
#import "SpotifySearchTableViewController.h"
#import "SoundCloudSearchTableViewController.h"
#import "PlaylistTableViewController.h"
#import "SPTAudioStreamingController+WHSpotifyHelper.h"
#import "MyMusicTableViewController.h"
#import "AccountTableViewController.h"
#import "SearchTabsNavigationViewController.h"
#import <Spotify/SPTDiskCache.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>
#import "SoundCloud.h"
#import "SoundCloud+Helper.h"
#import "kSoundcloud.h"



@interface TabBarViewController () <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, NowPlayingBarViewDelegate, SpotifySearchTableViewControllerDelegate, PlaylistTableViewControllerDelegate, MyMusicTableViewControllerDelegate, AccountTableViewControllerDelegate, SoundCloudSearchTableViewControllerDelegate, SoundCloudPlayerDelegate>

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NowPlayingBarView *nowPlayingBarView;

@end

@implementation TabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self setDelegates];
    [self setupNowPlayingBottomBar];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self handleNewSession];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self handlePlaybackPosition];
}



#pragma mark - Private

- (void)rewind
{
    // TODO: switch reference to SoundCloud or Spotify
    [self.player skipPrevious:nil];
}


- (void)playPause
{
    [self forActiveMusicPlayerSpotify:^
    {
        [self.player setIsPlaying:!self.player.isPlaying callback:nil];
        [self.player updateCurrentPlaybackPosition];
        
    } soundCloud:^
    {
        [[SoundCloud player] _setIsPlaying:![SoundCloud player].isPlaying];
        [[SoundCloud player] updateCurrentPlaybackPosition];
    }];
    
    [self updateDurationUI];
}


- (void)fastForward
{
    // TODO: switch reference to SoundCloud or Spotify
    [self.player skipNext:nil];
}



#pragma mark - Helper methods

- (void)setDelegates
{
    [self.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         switch ((WHSpotifyTabViews)idx) {
             case WHSpotifyTabSaved:
                 ((MyMusicTableViewController *)[(UINavigationController *)obj topViewController]).delegate = self;
                 break;
                 
             case WHSpotifyTabSearch:
             {
                 SearchTabsNavigationViewController *searchTabs = [(SearchTabsNavigationViewController *)[obj topViewController] init];
                 searchTabs.spotifySearchTableViewController.delegate = self;
                 searchTabs.soundCloudSearchTableViewController.delegate = self;
                 break;
             }
                 
             case WHSpotifyTabPlaylists:
                 ((PlaylistTableViewController *)[(UINavigationController *)obj topViewController]).delegate = self;
                 break;
                 
             case WHSpotifyTabUser:
                 ((AccountTableViewController *)[(UINavigationController *)obj topViewController]).delegate = self;
                 break;
                 
             default:
                 break;
         }
     }];
    
    [SoundCloud player].delegate = self;
}


- (void)setupNowPlayingBottomBar
{
    self.nowPlayingBarView = [[NowPlayingBarView alloc] initInViewController:self];
    [self.nowPlayingBarView assignBarActionWithTarget:self playPauseAction:@selector(playPause) nextTrackAction:@selector(fastForward) previousTrackAction:@selector(rewind)];
}


- (void)spt_updateUI
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player.currentTrackURI == nil) {
        return;
    }
    
    [SPTTrack trackWithURI:self.player.currentTrackURI
                   session:auth.session
                  callback:^(NSError *error, SPTTrack *track)
     {
         SPTPartialArtist *artist = [track.artists objectAtIndex:0];
         
         NSURL *imageURL = track.album.largestCover.imageURL;
         if (imageURL == nil) {
             NSLog(@"Album %@ doesn't have any images!", track.album);
             return;
         }
         
         // Pop over to a background queue to load the image over the network.
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
             NSError *error = nil;
             UIImage *image = nil;
             NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
             
             MPMediaItemArtwork *albumArt;
             
             if (imageData != nil) {
                 image = [UIImage imageWithData:imageData];
                 albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
             }
             
             // …and back to the main queue to display the image.
             dispatch_async(dispatch_get_main_queue(), ^
                            {
                                if (image == nil) {
                                    NSLog(@"Couldn't load cover image with error: %@", error);
                                    return;
                                }
                                
                                [self.nowPlayingBarView setSongTitle:track.name artist:artist.name albumArt:image duration:track.duration];
                                [self.player setNowPlayingInfoWithCurrentTrack:track.name artist:artist.name album:track.album.name duration:track.duration albumArt:albumArt];
                            });
         });
         
     }];
}


- (void)sc_updateUI
{
    [self setLastMusicOrigin:MusicOriginSoundCloud];
    
    NSDictionary *track = [[SoundCloud player] _getCurrentTrack];
    
    NSURL *imageURL = [NSURL URLWithString:track[kartwork_url]];
    if (imageURL == nil) {
        NSLog(@"Track %@ doesn't have any images!", track[ktitle]);
        return;
    }
    
    // Pop over to a background queue to load the image over the network.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSError *error = nil;
        UIImage *image = nil;
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL options:0 error:&error];
        
        MPMediaItemArtwork *albumArt;
        
        if (imageData != nil) {
            image = [UIImage imageWithData:imageData];
            albumArt = [[MPMediaItemArtwork alloc] initWithImage:image];
        }
        
        // …and back to the main queue to display the image.
        dispatch_async(dispatch_get_main_queue(), ^
        {
            if (image == nil) {
                NSLog(@"Couldn't load cover image with error: %@", error);
                return;
            }
            
            NSTimeInterval duration = [track[kduration] integerValue]/1000;
            
            [self.nowPlayingBarView setSongTitle:track[ktitle] artist:track[kuser][kusername] albumArt:image duration:duration];
            [[SoundCloud player] setNowPlayingInfoWithCurrentTrack:track[ktitle] artist:track[kuser][kusername] album:nil duration:duration albumArt:albumArt];
        });
    });
}



- (void)handleNewSession
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    if (self.player == nil) {
        self.player = [[SPTAudioStreamingController alloc] initWithClientId:auth.clientID];
        self.player.playbackDelegate = self;
        self.player.diskCache = [[SPTDiskCache alloc] initWithCapacity:1024 * 1024 * 64];
        [self.player initControlCenterWithTarget:self playPauseAction:@selector(playPause) rewindAction:@selector(rewind) fastForwardAction:@selector(fastForward)];
    }
    
    [self.player loginWithSession:auth.session callback:^(NSError *error) {
        
        if (error != nil) {
            NSLog(@"*** Enabling playback got error: %@", error);
            return;
        }
        
        // FIXME: enable all functionality here
        [self spt_updateUI];
    }];
}


/**
 *  This method is needed in order for the now playing button bar to be updated
 *  with the currently playing track.
 *
 *  Use at viewWillAppear and nowPlayingBarDelegate willEnterForeground
 */
- (void)handlePlaybackPosition
{
    if (self.player != nil || [SoundCloud player])
        [self.nowPlayingBarView updateUI];
}


- (id)nowPlayingTrackItem
{
    switch ([self getActiveMusicOrigin])
    {
        case MusicOriginSpotify:
        {
            return self.player;
            break;
        }
            
        case MusicOriginSoundCloud:
        {
            return [SoundCloud player];
            break;
        }
    }
}


- (MusicOrigin)getActiveMusicOrigin
{
    if (([SoundCloud player] || [[SoundCloud player] isPlaying])
        && ![self.player isPlaying])
    {
        return MusicOriginSoundCloud;
    }
    else if ((self.player || [self.player isPlaying])
             && ![[SoundCloud player] isPlaying])
    {
        return MusicOriginSpotify;
    }
    else
    {
        return MusicOriginSoundCloud;
    }
}


- (void)forMusicPlayerSpotify:(void (^)(void))spotifyBlock soundCloud:(void (^)(void))soundCloudBlock
{
    switch ([self getActiveMusicOrigin])
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


- (void)updateDurationUI
{
    double currentPosition, totalDuration;
    
    switch (self.lastMusicOrigin)
    {
        case MusicOriginSpotify:
        {
            currentPosition = [self.player currentPlaybackPosition];
            totalDuration = [self.player currentTrackDuration];
            
            [self.nowPlayingBarView setPlaying:self.player.isPlaying];
            [self setLastMusicOrigin:MusicOriginSpotify];
            break;
        }
            
        case MusicOriginSoundCloud:
        {
            currentPosition = [[SoundCloud player] currentPlaybackPosition].doubleValue;
            totalDuration = [[SoundCloud player] currentTrackDuration].doubleValue;
            
            [self.nowPlayingBarView setPlaying:[SoundCloud player].isPlaying];
            [self setLastMusicOrigin:MusicOriginSoundCloud];
            break;
        }
    }
    
    [self.nowPlayingBarView setCurrentDurationPosition:currentPosition totalDuration:totalDuration];
}



#pragma mark - Spotify Track Player Delegates

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didFailToPlayTrack:(NSURL *)trackUri
{
    NSLog(@"failed to play track: %@", trackUri);
    [self.player setIsPlaying:NO callback:nil];
    
    // FIXME: Handle when track can't play and unload track from deck.
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata
{
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
    [self spt_updateUI];
    [self setLastMusicOrigin:MusicOriginSpotify];
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying
{
    // TODO: switch reference to SoundCloud or Spotify
    [self.nowPlayingBarView setCurrentDurationPosition:self.player.currentPlaybackPosition totalDuration:self.player.currentTrackDuration];
    [self.nowPlayingBarView setPlaying:isPlaying];
    NSLog(@"is playing = %d", isPlaying);
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset
{
    [self updateDurationUI];
    
    [self forMusicPlayerSpotify:^
    {
        [self.player updateCurrentPlaybackPosition];
        
    } soundCloud:^
    {
        [[SoundCloud player] updateCurrentPlaybackPosition];
    }];
}



#pragma mark - SoundCloud Player Delegate

- (void)soundCloud:(SoundCloud *)soundcloud didChangePlaybackStatus:(BOOL)playing
{
//    [self.nowPlayingBarView setPlaying:playing];
    [[SoundCloud player] updateCurrentPlaybackPosition];
}


- (void)soundCloud:(SoundCloud *)soundcloud didSeekToOffset:(NSTimeInterval)offset
{
    [self.nowPlayingBarView setCurrentDurationPosition:(double)offset totalDuration:self.player.currentTrackDuration];
//    [self.nowPlayingBarView setPlaying:[SoundCloud player].isPlaying];
    [[SoundCloud player] updateCurrentPlaybackPosition];
}


- (void)soundCloud:(SoundCloud *)soundcloud didChangeToTrack:(NSDictionary *)trackMetadata
{
    
}


- (void)soundCloud:(SoundCloud *)soundcloud didFailToPlayTrack:(NSURL *)trackUri
{
    
}



#pragma mark - Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}



#pragma mark - NowPlayingBarView Delegate

- (void)nowPlayingBar:(NowPlayingBarView *)nowPlayingBar playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position
{
    // TODO: Split/switch between SoundCloud and AVPlayer
    [self.player seekToOffset:position callback:nil];
    
    [[[SoundCloud player] avPlayer].currentItem seekToTime:CMTimeMakeWithSeconds(position, 60000)];
    [[SoundCloud player] updateCurrentPlaybackPosition];
    
    // TODO: Update view calling from SoundCloud delegate
}


- (void)nowPlayingBar:(NowPlayingBarView *)nowPlayingBar willEnterForeground:(BOOL)finished
{
    [self handlePlaybackPosition];
}



#pragma mark - SpotifySearchTableViewController Delegate

- (void)spotifySearchTableViewController:(SpotifySearchTableViewController *)tableView didSelectTrack:(SPTTrack *)track atIndexPath:(NSIndexPath *)indexPath
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [SPTTrack trackWithURI:track.uri session:auth.session callback:^(NSError *error, id object) {
        NSArray *tracks = @[track.playableUri];
        [self.player playURIs:tracks fromIndex:0 callback:nil];
        [self.player confirmTrackIsPlaying:nil isNotPlaying:^{
            NSLog(@"buffering track...");
        }];
    }];
}


#pragma mark - SoundCloudSearchTableViewController Delegate

- (void)soundCloudSearchTableViewController:(SoundCloudSearchTableViewController *)tableView didSelectTrack:(id)track atIndexPath:(NSIndexPath *)indexPath
{
    [[SoundCloud player] _loadAndPlayTrack:track];
    [self sc_updateUI];
    [self.nowPlayingBarView setCurrentDurationPosition:0 totalDuration:[track[kduration] integerValue]];
    [self.nowPlayingBarView setPlaying:YES];
}



#pragma mark - PlaylistTableViewController Delegate

- (void)playlistTableView:(PlaylistTableViewController *)view didSelectPlaylist:(SPTPartialPlaylist *)playlist userInfo:(NSDictionary *)userInfo
{
    // FIXME: switch between spotify playlist table or SoundCloud
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [SPTPlaylistSnapshot playlistWithURI:playlist.playableUri session:auth.session callback:^(NSError *error, id object)
     {
         NSIndexPath *indexPath = [userInfo objectForKey:IndexPathKey];
         
         [self.player playURIs:@[playlist.playableUri] fromIndex:(indexPath ? (int)indexPath.row : 0) callback:nil];
         [self.player confirmTrackIsPlaying:nil isNotPlaying:^{
             NSLog(@"buffering track...");
         }];
     }];
}



#pragma mark - MyMusicTableViewController Delegate

- (void)myMusicTableViewController:(MyMusicTableViewController *)tableView didSelectTrack:(SPTTrack *)track userInfo:(NSDictionary *)userInfo
{
    // FIXME: switch between spotify playlist table or SoundCloud
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [SPTTrack trackWithURI:track.uri session:auth.session callback:^(NSError *error, id object) {
        NSArray *tracks = @[track.playableUri];
        [self.player playURIs:tracks fromIndex:0 callback:nil];
        [self.player confirmTrackIsPlaying:nil isNotPlaying:^{
            NSLog(@"buffering track...");
        }];
    }];
}



#pragma mark - AccountTableViewController Delegate

- (void)accountTableView:(AccountTableViewController *)tableView didSelectLogout:(BOOL)didSelectLogout
{
    if (didSelectLogout)
    {
        SPTAuth *auth = [SPTAuth defaultInstance];
        if (self.player)
        {
            [self.player logout:^(NSError *error)
            {
                auth.session = nil;
                [self.navigationController popViewControllerAnimated:YES];
            }];
        }
        else
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

@end
