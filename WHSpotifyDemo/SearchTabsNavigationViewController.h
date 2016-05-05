//
//  SearchTabsNavigationViewController.h
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 5/5/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    SearchServiceSpotify,
    SearchServiceSoundCloud
}SearchServices;

@class SpotifySearchTableViewController, SoundCloudSearchTableViewController;

@interface SearchTabsNavigationViewController : UINavigationController

@property (strong, nonatomic) SpotifySearchTableViewController *spotifySearchTableViewController;
@property (strong, nonatomic) SoundCloudSearchTableViewController *soundCloudSearchTableViewController;

@end
