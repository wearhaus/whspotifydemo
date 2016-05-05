//
//  TabBarViewController.h
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    WHSpotifyTabSaved,
    WHSpotifyTabPlaylists,
    WHSpotifyTabSearch,
    WHSpotifyTabUser
}WHSpotifyTabViews;


typedef enum {
    MusicOriginSpotify,
    MusicOriginSoundCloud,
}MusicOrigin;

@interface TabBarViewController : UITabBarController <UITabBarControllerDelegate>

@property (nonatomic) MusicOrigin lastMusicOrigin;

@end
