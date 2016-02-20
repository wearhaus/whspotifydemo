//
//  PlaylistTableViewController.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/15/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyMusicTableViewController.h"
#import <Spotify/Spotify.h>


@protocol PlaylistTableViewControllerDelegate;

@interface PlaylistTableViewController : UITableViewController <MyMusicTableViewControllerDelegate>
{
    SPTPartialPlaylist *lastSelectedPlaylist;
}

@property (strong, nonatomic) NSArray *playlists;
@property (weak) NSObject<PlaylistTableViewControllerDelegate> *delegate;

@end


@protocol PlaylistTableViewControllerDelegate <NSObject>
@optional
- (void)playlistTableView:(PlaylistTableViewController *)view didSelectPlaylist:(SPTPartialPlaylist *)playlist userInfo:(NSDictionary *)userInfo;
@end