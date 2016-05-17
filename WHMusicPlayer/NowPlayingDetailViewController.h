//
//  NowPlayingDetailViewController.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/5/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DurationPositionBarManager.h"
#import "kMusicServices.h"


@protocol NowPlayingDetailViewControllerDelegate;

@interface NowPlayingDetailViewController : UIViewController <DurationPositionBarManagerDelegate>
{
    DurationPositionBarManager *durationPositionManager;
}

@property (nonatomic, getter=isPlaying) BOOL playing;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIView *albumSwipeView;
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (weak, nonatomic) IBOutlet UIView *progressBarTouch;
@property (weak, nonatomic) IBOutlet UIView *progressBarDuration;
@property (weak, nonatomic) IBOutlet UIView *progressBarView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UILabel *musicServiceOriginLabel;
@property (weak, nonatomic) IBOutlet UIView *musicServiceColorLabel;
@property (weak) NSObject<NowPlayingDetailViewControllerDelegate> *delegate;

/**
 *  Sets the song metadata for the view.
 */
- (void)setSongTitle:(NSString *)title artist:(NSString *)artist albumArt:(UIImage *)albumArt duration:(NSTimeInterval)duration origin:(MusicOrigin)origin;
- (void)setSongTitle:(NSString *)title;
- (void)setSongArtist:(NSString *)artist;
- (void)setSongAlbumArt:(UIImage *)albumArt;
/**
 *  Sets the current duration position of the song for the view.
 */
- (void)setCurrentDurationPosition:(double)current totalDuration:(double)total;

- (IBAction)hideButton_pressed:(id)sender;
- (IBAction)playButton_pressed:(id)sender;
- (IBAction)nextButton_pressed:(id)sender;
- (IBAction)previousButton_pressed:(id)sender;

@end


@protocol NowPlayingDetailViewControllerDelegate <NSObject>
/**
 *  Fires when the user changes the position on the now playing bar.
 */
- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position;
/**
 *  Fires when the user changes the track to the next track in the queue.
 */
- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view didTapNextTrack:(BOOL)tapped;
/**
 *  Fires when the user changes the track to the previous track in the queue.
 */
- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view didTapPreviousTrack:(BOOL)tapped;
/**
 *  Fires when the user pauses the current track.
 */
- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view didTapPlayPauseTrack:(BOOL)tapped;
@end