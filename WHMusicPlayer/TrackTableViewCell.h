//
//  SpotifyTrackTableViewCell.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/3/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TrackTableViewCellIdentifier @"TrackTableViewCell"
#define TrackTableViewCellHeight 48

@interface TrackTableViewCell : UITableViewCell

@property (assign, nonatomic) id track;
@property (assign, nonatomic) IBOutlet UIView *musicServiceColorLabel;

- (void)addLongTapToQueueForTrack:(id)theTrack;

@end
