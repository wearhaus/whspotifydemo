//
//  NowPlayingDetailViewController.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/5/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "NowPlayingDetailViewController.h"


@interface NowPlayingDetailViewController ()

@end

@implementation NowPlayingDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    durationPositionManager = [[DurationPositionBarManager alloc] initWithView:self.progressBarView positionView:self.progressBarDuration touchView:self.progressBarTouch];
    durationPositionManager.delegate = self;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}



#pragma mark - Public

- (void)setSongTitle:(NSString *)title
{
    [self.titleLabel setText:title];
}


- (void)setSongArtist:(NSString *)artist
{
    [self.artistLabel setText:artist];
}


- (void)setSongAlbumArt:(UIImage *)albumArt
{
    [self.albumArtImageView setImage:albumArt];
}


- (void)setSongTitle:(NSString *)title artist:(NSString *)artist albumArt:(UIImage *)albumArt duration:(NSTimeInterval)duration origin:(MusicOrigin)origin
{
    [self setSongTitle:title];
    [self setSongArtist:artist];
    [self setSongAlbumArt:albumArt];
    [self setMusicServiceOrigin:origin];
}


- (void)setCurrentDurationPosition:(double)current totalDuration:(double)total
{
    [durationPositionManager setCurrentDurationPosition:current totalDuration:total];
}


- (void)setMusicServiceOrigin:(MusicOrigin)origin
{
    switch (origin)
    {
        case MusicOriginSpotify:
        {
            [self.musicServiceOriginLabel setText:@"Playing from Spotify"];
            [self.progressBarDuration setBackgroundColor:COLOR_SPOTIFY];
            [self.musicServiceColorLabel setBackgroundColor:COLOR_SPOTIFY];
            break;
        }
            
        case MusicOriginSoundCloud:
        {
            [self.musicServiceOriginLabel setText:@"Playing from SoundCloud"];
            [self.progressBarDuration setBackgroundColor:COLOR_SOUNDCLOUD];
            [self.musicServiceColorLabel setBackgroundColor:COLOR_SOUNDCLOUD];
            break;
        }
    }
}


- (void)setPlaying:(BOOL)playing
{
    [self.playPauseButton setImage:[UIImage imageNamed:playing ? @"iconPause" : @"iconPlay"] forState:UIControlStateNormal];
    [durationPositionManager updatePlaybackStatePlaying:playing];
    _playing = playing;
}



#pragma mark - Duration Position Delegate

- (void)playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position sender:(id)sender
{
    [self.delegate nowPlayingDetailView:self playbackPositionDidTapToChangeToPosition:position];
}


- (void)playbackPositionDidChangeToPosition:(NSTimeInterval)position duration:(NSTimeInterval)duration sender:(id)sender
{
}



#pragma mark - Actions

- (IBAction)hideButton_pressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)playButton_pressed:(id)sender
{
    [self.delegate nowPlayingDetailView:self didTapPlayPauseTrack:YES];
    [self setPlaying:!self.isPlaying];
}


- (IBAction)nextButton_pressed:(id)sender
{
    [self.delegate nowPlayingDetailView:self didTapNextTrack:YES];
}


- (IBAction)previousButton_pressed:(id)sender
{
    [self.delegate nowPlayingDetailView:self didTapPreviousTrack:YES];
}

@end
