//
//  NowPlayingBarView.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 1/21/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DurationPositionBarManager.h"
#import "NowPlayingDetailViewController.h"
#import "kMusicServices.h"


@protocol NowPlayingBarViewDelegate;

/**
 *  A view that sits at the bottom of the screen to control playback and
 *  display what is currently playing.
 */
@interface NowPlayingBarView : UIView <UIGestureRecognizerDelegate, DurationPositionBarManagerDelegate, NowPlayingDetailViewControllerDelegate>
{
    id actionTarget;
    SEL playPauseAction;
    SEL nextTrackAction;
    SEL previousTrackAction;
    DurationPositionBarManager *durationPositionManager;
    NowPlayingDetailViewController *detailViewController;
}

@property (nonatomic, getter=isVisible) BOOL visible;
@property (nonatomic, getter=isPlaying) BOOL playing;
@property (assign, nonatomic) UIViewController *parentViewController;
@property (weak) NSObject<NowPlayingBarViewDelegate> *delegate;

@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIView *progressBarView;
@property (weak, nonatomic) IBOutlet UIView *progressBarDuration;
@property (weak, nonatomic) IBOutlet UIView *progressBarTouch;
@property (weak, nonatomic) IBOutlet UIView *musicServiceColorLabel;

@property (nonatomic) NSTimeInterval duration;

- (instancetype)initInViewController:(UIViewController *)viewController;
/**
 *  Assigns actions associated with user button presses.
 */
- (void)assignBarActionWithTarget:(id)target playPauseAction:(SEL)actionPlayPause nextTrackAction:(SEL)actionNextTrack previousTrackAction:(SEL)actionPreviousTrack;
/**
 *  Sets the song metadata for the view.
 */
- (void)setSongTitle:(NSString *)title artist:(NSString *)artist albumArt:(UIImage *)albumArt duration:(NSTimeInterval)duration origin:(MusicOrigin)origin;
- (void)setSongTitle:(NSString *)title;
- (void)setSongArtist:(NSString *)artist;
- (void)setSongAlbumArt:(UIImage *)albumArt;

/**
 *  Set the origin of the music
 */
- (void)setMusicServiceOrigin:(MusicOrigin)origin;
/**
 *  This method should be set in a delegate method that handles actual playback
 *  and not user actions.
 */
- (void)setPlaying:(BOOL)playing;
/**
 *  Sets the current duration position of the song for the view.
 */
- (void)setCurrentDurationPosition:(double)current totalDuration:(double)total;
/**
 *  Forces the view to update to ensure all song metadata is accurate.
 */
- (void)updateUI;
/**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           *  Shows the now playing bar.
 */
- (void)show;
/**
 *  Hides the now playing bar.
 */
- (void)hide;

- (IBAction)playPauseButton_pressed:(id)sender;

@end



@protocol NowPlayingBarViewDelegate <NSObject>
/**
 *  Fires when the user changes the position on the now playing bar.
 */
- (void)nowPlayingBar:(NowPlayingBarView *)nowPlayingBar playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position;

@optional
/**
 *  Mainly setup to handle track position when activating from background.
 *
 *  TODO: Setup viewWillAppear to run the same method so updating the bar
 *  remains consistent.
 */
- (void)nowPlayingBar:(NowPlayingBarView *)nowPlayingBar willEnterForeground:(BOOL)finished;
@end