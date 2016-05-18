//
//  PlaylistTableViewCell.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/12/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "PlaylistTableViewCell.h"
#import "Haneke.h"


@implementation PlaylistTableViewCell

- (void)initWithPlaylistTitle:(NSString *)title playlistSubtitle:(NSString *)subtitle playlistImageURL:(NSURL *)imageURL
{
    self.playlistTitle.text = title;
    self.playlistSubtitle.text = subtitle;
    
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [self.playlistImage hnk_setImageFromURL:imageURL placeholder:[UIImage imageNamed:@"PlaylistDefault"]];
}

@end
