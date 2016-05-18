//
//  NowPlayingDetailViewController.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/5/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "NowPlayingDetailViewController.h"


@interface NowPlayingDetailViewController () <UIGestureRecognizerDelegate>
{
    CGRect originalFrame;
}
@end

@implementation NowPlayingDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    durationPositionManager = [[DurationPositionBarManager alloc] initWithView:self.progressBarView positionView:self.progressBarDuration touchView:self.progressBarTouch];
    durationPositionManager.delegate = self;
}


- (void)viewDidAppear:(BOOL)animated
{
    if (CGRectIsEmpty(originalFrame))
    {
        originalFrame = self.albumSwipeView.frame;
        [self addSwipeGestures];
    }
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



#pragma mark - Private

- (void)addSwipeGestures
{
    // add pan recognizer to the view when initialized
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    
    [panRecognizer setDelegate:self];
    [self.albumSwipeView addGestureRecognizer:panRecognizer]; // add to the view you want to detect swipe on
}


-(void)panRecognized:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        // you might want to do something at the start of the pan
    }
    
    CGPoint distance = [sender translationInView:self.albumSwipeView]; // get distance of pan/swipe in the view in which the gesture recognizer was added
    
    CGFloat x = originalFrame.origin.x;
    CGPoint newOrigin = { .x = x+distance.x, .y = originalFrame.origin.y };
    CGRect newFrame = { .origin = newOrigin, .size = originalFrame.size };
    
    self.albumSwipeView.frame = newFrame;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [sender cancelsTouchesInView]; // you may or may not need this - check documentation if unsure
        if (distance.x > 20) { // right
            [self previousButton_pressed:nil];
        } else if (distance.x < -20) { //left
            [self nextButton_pressed:nil];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.albumSwipeView.frame = originalFrame;
        }];
        // Note: if you don't want both axis directions to be triggered (i.e. up and right) you can add a tolerence instead of checking the distance against 0 you could check for greater and less than 50 or 100, etc.
    }
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
