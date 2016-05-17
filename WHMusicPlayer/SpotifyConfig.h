//
//  SpotifyConfig.h
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#ifndef SpotifyConfig_h
#define SpotifyConfig_h

// For an in-depth auth demo, see the "Basic Auth" demo project supplied with the SDK.
// Don't forget to add your callback URL's prefix to the URL Types section in the target's Info pane!

// Your client ID
#define kClientId "2cea8fd1e7e841c0b283944b74240eda"

// Your applications callback URL
#define kCallbackURL "spotifyiossdkexample://"

// The URL to your token swap endpoint
// If you don't provide a token swap service url the login will use implicit grant tokens, which means that your user will need to sign in again every time the token expires.

// #define kTokenSwapServiceURL "http://192.168.1.111:1234/swap"

// The URL to your token refresh endpoint
// If you don't provide a token refresh service url, the user will need to sign in again every time their token expires.

// #define kTokenRefreshServiceURL "http://localhost:1234/refresh"


#define kSessionUserDefaultsKey "SpotifySession"

#endif /* SpotifyConfig_h */
