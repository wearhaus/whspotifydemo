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
#import "PlaylistTableViewController.h"
#import "SPTAudioStreamingController+WHSpotifyHelper.h"
#import "MyMusicTableViewController.h"
#import "AccountTableViewController.h"
#import <Spotify/SPTDiskCache.h>
#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>
#import <MediaPlayer/MPMediaQuery.h>
#import <MediaPlayer/MPRemoteCommandCenter.h>
#import <MediaPlayer/MPRemoteCommand.h>
#import "SoundCloud.h"
#import "kSoundcloud.h"



@interface TabBarViewController () <SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, SPTAudioStreamingDelegate, NowPlayingBarViewDelegate, SpotifySearchTableViewControllerDelegate, PlaylistTableViewControllerDelegate, MyMusicTableViewControllerDelegate, AccountTableViewControllerDelegate>

@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) NowPlayingBarView *nowPlayingBarView;

@end

@implementation TabBarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self setDelegates];
    
    // setup now playing bottom bar
//    self.nowPlayingBarView = [[NowPlayingBarView alloc] initInViewController:self];
//    [self.nowPlayingBarView assignBarActionWithTarget:self playPauseAction:@selector(playPause) nextTrackAction:@selector(fastForward) previousTrackAction:@selector(rewind)];
    
    
    // temp soundcloud
//    [SoundCloud performSearchWithQuery:@"madeintyo i want" userInfo:@{} callback:^(id responseObject) {
//        
//        [[SoundCloud player] _loadAndPlayURLString:responseObject[0][kstream_url]];
//        NSLog(@"\n\n[debug] %@\n\n", @"Succesfully got track information from search.");
//        
//    }];
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
    [self.player skipPrevious:nil];
}


- (void)playPause
{
    [self.player setIsPlaying:!self.player.isPlaying callback:nil];
    [self.player updateCurrentPlaybackPosition];
}


- (void)fastForward
{
    [self.player skipNext:nil];
}


- (void)updateUI
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
        
        // TODO: enable all functionality here
        [self updateUI];
        
//        NSURLRequest *playlistReq = [SPTPlaylistSnapshot createRequestForPlaylistWithURI:[NSURL URLWithString:@"spotify:user:cariboutheband:playlist:4Dg0J0ICj9kKTGDyFu0Cv4"]
//                                                                             accessToken:auth.session.accessToken
//                                                                                   error:nil];
//        [[SPTRequest sharedHandler] performRequest:playlistReq callback:^(NSError *error, NSURLResponse *response, NSData *data) {
//            if (error != nil) {
//                NSLog(@"*** Failed to get playlist %@", error);
//                return;
//            }
//            SPTPlaylistSnapshot *playlistSnapshot = [SPTPlaylistSnapshot playlistSnapshotFromData:data withResponse:response error:nil];
//            [self.player playURIs:playlistSnapshot.firstTrackPage.items fromIndex:0 callback:nil];
//        }];
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
    if (self.player != nil)
        [self.nowPlayingBarView updateUI];
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
                 ((SpotifySearchTableViewController *)[(UINavigationController *)obj topViewController]).delegate = self;
                 break;
                 
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
}



#pragma mark - Track Player Delegates

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
    
    // TODO: Handle when track can't play and unload track from deck.
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata
{
    NSLog(@"track changed = %@", [trackMetadata valueForKey:SPTAudioStreamingMetadataTrackURI]);
    [self updateUI];
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying
{
    [self.nowPlayingBarView setCurrentDurationPosition:self.player.currentPlaybackPosition totalDuration:self.player.currentTrackDuration];
    [self.nowPlayingBarView setPlaying:isPlaying];
    NSLog(@"is playing = %d", isPlaying);
}


- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didSeekToOffset:(NSTimeInterval)offset
{
    [self.nowPlayingBarView setCurrentDurationPosition:self.player.currentPlaybackPosition totalDuration:self.player.
     currentTrackDuration];
    [self.nowPlayingBarView setPlaying:self.player.isPlaying];
    [self.player updateCurrentPlaybackPosition];
}



#pragma mark - Tab Bar Controller Delegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    
}



#pragma mark - NowPlayingBarView Delegate

- (void)nowPlayingBar:(NowPlayingBarView *)nowPlayingBar playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position
{
    [self.player seekToOffset:position callback:nil];
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



#pragma mark - PlaylistTableViewController Delegate

- (void)playlistTableView:(PlaylistTableViewController *)view didSelectPlaylist:(SPTPartialPlaylist *)playlist userInfo:(NSDictionary *)userInfo
{
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
