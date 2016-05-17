//
//  SoundCloudSearchTableViewController.h
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 4/27/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SoundCloudSearchTableViewControllerDelegate;

/**
 *  A table view controller that will help with searching and choosing a track
 *  from SoundCloud. Assigning a delegate will return the Track object of the
 *  track the user has selected.
 */
@interface SoundCloudSearchTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *searchResults;
@property (weak) NSObject<SoundCloudSearchTableViewControllerDelegate> *delegate;

@end


@protocol SoundCloudSearchTableViewControllerDelegate <NSObject>
// TODO: create delegate for when track is playing
@optional
- (void)soundCloudSearchTableViewController:(SoundCloudSearchTableViewController *)tableView didSelectTrack:(id)track atIndexPath:(NSIndexPath *)indexPath;
@end