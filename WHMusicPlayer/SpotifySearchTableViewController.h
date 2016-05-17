//
//  SpotifySearchTableViewController.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 1/27/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SPTTrack;
@protocol SpotifySearchTableViewControllerDelegate;

/**
 *  A table view controller that will help with searching and choosing a track
 *  from Spotify. Assigning a delegate will return the SPTTrack object of the
 *  track the user has selected.
 */
@interface SpotifySearchTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (weak) NSObject<SpotifySearchTableViewControllerDelegate> *delegate;

@end

@protocol SpotifySearchTableViewControllerDelegate <NSObject>
@optional
- (void)spotifySearchTableViewController:(SpotifySearchTableViewController *)tableView didSelectTrack:(SPTTrack *)track atIndexPath:(NSIndexPath *)indexPath;
- (void)spotifySearchTableViewController:(SpotifySearchTableViewController *)tableView didLoadView:(BOOL)loaded;
@end