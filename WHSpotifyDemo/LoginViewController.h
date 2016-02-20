//
//  LoginViewController.h
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>

@interface LoginViewController : UIViewController

@property (atomic, readwrite) SPTAuthViewController *authViewController;

- (IBAction)loginButton_clicked:(id)sender;

@end
