//
//  PlaylistTableViewCell.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/12/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PlaylistTableViewCellIdentifier @"PlaylistTableViewCell"
#define PlaylistTableViewCellHeight 52

@interface PlaylistTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *playlistTitle;
@property (weak, nonatomic) IBOutlet UILabel *playlistSubtitle;
@property (weak, nonatomic) IBOutlet UIImageView *playlistImage;

@end
