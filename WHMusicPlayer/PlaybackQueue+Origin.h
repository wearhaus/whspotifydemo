//
//  PlaybackQueue+Origin.h
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 5/6/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "PlaybackQueue.h"
#import "kMusicServices.h"


@interface PlaybackQueue (Origin)

- (void)changeLastMusicOrigin:(MusicOrigin)lastMusicOrigin;
- (void)forActiveMusicPlayerSpotify:(void (^)(void))spotifyBlock soundCloud:(void (^)(void))soundCloudBlock;

@end