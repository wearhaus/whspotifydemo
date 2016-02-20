//
//  MyMusicTableViewController.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/17/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>


static NSString *PlaylistURIKey = @"PlaylistURIKey";
static NSString *IndexPathKey = @"IndexPathKey";


@protocol MyMusicTableViewControllerDelegate;

@interface MyMusicTableViewController : UITableViewController
{
    NSURL *playlistURI;
}

@property (strong, nonatomic) NSArray *tracks;
@property (weak) NSObject<MyMusicTableViewControllerDelegate> *delegate;

- (instancetype)initWithoutAutoload;

/**
 *  Sets up the view depending on the context and source of the tracks. Tracks 
 *  can be loaded either from a list of tracks or playlist items. 
 *
 *  A title can be set through this convenience method, but because of the 
 *  possible delay of tracks loading, it may be a good idea to also set the 
 *  title prior to this.
 *
 *  UserInfo is available to set the context of the tracks, especially if the
 *  tracks came from a playlist.
 *
 */
- (void)loadTracksWithItems:(NSArray *)tracks title:(NSString *)title showsCancelButton:(BOOL)showsCancel userInfo:(NSDictionary *)userInfo;

@end


@protocol MyMusicTableViewControllerDelegate <NSObject>
@optional
/**
 *  Runs after a user selects a track from the table view list. Depending on the
 *  context of the tracks, UserInfo can provide information like the source
 *  playlist and its URI.
 */
- (void)myMusicTableViewController:(MyMusicTableViewController *)tableView didSelectTrack:(SPTTrack *)track userInfo:(NSDictionary *)userInfo;
@end