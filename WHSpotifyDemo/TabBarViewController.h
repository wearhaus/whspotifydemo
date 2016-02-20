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

@interface TabBarViewController : UITabBarController <UITabBarControllerDelegate>

@end
