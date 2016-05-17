//
//  SearchTabsNavigationViewController.h
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 5/5/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotifySearchTableViewController.h"
#import "SoundCloudSearchTableViewController.h"


typedef enum {
    SearchServiceSpotify,
    SearchServiceSoundCloud
}SearchServices;


@interface SearchTabsNavigationViewController : UINavigationController <SpotifySearchTableViewControllerDelegate>

@property (strong, nonatomic) SpotifySearchTableViewController *spotifySearchTableViewController;
@property (strong, nonatomic) SoundCloudSearchTableViewController *soundCloudSearchTableViewController;
@property (assign, nonatomic) UISearchBar *searchBar;

@end
