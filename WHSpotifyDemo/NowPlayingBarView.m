//
//  NowPlayingBarView.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 1/21/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "NowPlayingBarView.h"
#import <QuartzCore/QuartzCore.h>


#define NowPlayingBarOffset     49

@implementation NowPlayingBarView
{
    CGPoint originalCenter;
    MusicOrigin currentOrigin;
}


#pragma mark - Public methods

- (instancetype)init
{
    self = [super init];
    {
        _visible = YES;
        _playing = NO;
        durationPositionManager = [[DurationPositionBarManager alloc] initWithView:self.progressBarView positionView:self.progressBarDuration touchView:self.progressBarTouch];
        durationPositionManager.delegate = self;
        [durationPositionManager setPlaybackPosition:0];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [self setupBackgroundNotification];
    }
    return self;
}


- (instancetype)initInViewController:(UIViewController *)viewController
{
    self = [[[[NSBundle mainBundle] loadNibNamed:@"NowPlayingBarView" owner:self options:nil] firstObject] init];;
    {
        CGRect nowPlayingViewFrameBottom = viewController.view.frame;
        nowPlayingViewFrameBottom.size = self.frame.size;
        nowPlayingViewFrameBottom.size.width = viewController.view.frame.size.width;
        nowPlayingViewFrameBottom.origin.y = viewController.view.frame.size.height - self.frame.size.height - NowPlayingBarOffset;
        self.frame = nowPlayingViewFrameBottom;
        self.delegate = (id)viewController;
        self.parentViewController = viewController;
        [self addSwipeGestures];
        [self addTapGesture];
        [self hide];
        
        [viewController.view addSubview:self];
    }
    return self;
}


- (void)layoutSubviews
{
    originalCenter = self.slideView.center;
}


- (void)assignBarActionWithTarget:(id)target playPauseAction:(SEL)actionPlayPause nextTrackAction:(SEL)actionNextTrack previousTrackAction:(SEL)actionPreviousTrack
{
    actionTarget = target;
    playPauseAction = actionPlayPause;
    nextTrackAction = actionNextTrack;
    previousTrackAction = actionPreviousTrack;
}


- (void)show
{
    if ([self isVisible]) return;
    _visible = YES;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFramePosition = self.frame;
        newFramePosition.origin.y -= self.frame.size.height;
        
        self.frame = newFramePosition;
        self.hidden = NO;
    }];
}


- (void)hide
{
    if (![self isVisible]) return;
    _visible = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect newFramePosition = self.frame;
        newFramePosition.origin.y += self.frame.size.height;
        
        self.frame = newFramePosition;
    } completion:^(BOOL finished) {
        if (finished)
            self.hidden = YES;
    }];
}


- (void)setSongTitle:(NSString *)title
{
    self.titleLabel.text = title;
}


- (void)setSongArtist:(NSString *)artist
{
    self.artistLabel.text = artist;
}


- (void)setSongAlbumArt:(UIImage *)albumArt
{
    self.albumArtImageView.image = albumArt;
}


- (void)setMusicServiceOrigin:(MusicOrigin)origin
{
    switch (origin)
    {
        case MusicOriginSpotify:
        {
            currentOrigin = MusicOriginSpotify;
            [self.progressBarDuration setBackgroundColor:[UIColor colorWithRed:50./255 green:205./255 blue:100./255 alpha:1]];
            break;
        }
            
        case MusicOriginSoundCloud:
        {
            currentOrigin = MusicOriginSoundCloud;
            [self.progressBarDuration setBackgroundColor:[UIColor colorWithRed:255./255 green:153./255 blue:63./255 alpha:1]];
            break;
        }
    }
}


- (void)setSongTitle:(NSString *)title artist:(NSString *)artist albumArt:(UIImage *)albumArt duration:(NSTimeInterval)duration origin:(MusicOrigin)origin
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setDuration:duration];
        [self setSongTitle:title];
        [self setSongArtist:artist];
        [self setSongAlbumArt:albumArt];
        [self setMusicServiceOrigin:origin];
        [durationPositionManager setCurrentDurationPosition:0 totalDuration:duration];
        [self setPlaying:self.isPlaying];
        
        if (detailViewController != nil)
            [detailViewController setSongTitle:title artist:artist albumArt:albumArt duration:duration origin:origin];
    });
}


- (void)setCurrentDurationPosition:(double)current totalDuration:(double)total
{
    if (!total) return;
    
    [durationPositionManager setCurrentDurationPosition:current totalDuration:total];
    
    if (detailViewController != nil)
        [detailViewController setCurrentDurationPosition:current totalDuration:total];
}


- (void)setPlaying:(BOOL)playing
{
    [self.playPauseButton setImage:[UIImage imageNamed:playing ? @"iconPause" : @"iconPlay"] forState:UIControlStateNormal];
    _playing = playing;
    
    if ([self isPlaying] && ![self isVisible])
        [self show];
    
    [durationPositionManager updatePlaybackStatePlaying:playing];
    
    if (detailViewController != nil)
        [detailViewController setPlaying:playing];
    
    // TODO: find out when to hide bar
}


- (void)updateUI
{
    if (_visible)
        [self setPlaying:self.isPlaying];
}



#pragma mark - Private

- (void)addSwipeGestures
{
    // add pan recognizer to the view when initialized
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panRecognized:)];
    [panRecognizer setDelegate:self];
    [self.slideView addGestureRecognizer:panRecognizer]; // add to the view you want to detect swipe on
}


-(void)panRecognized:(UIPanGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        // you might want to do something at the start of the pan
    }
    
    CGPoint distance = [sender translationInView:self.slideView]; // get distance of pan/swipe in the view in which the gesture recognizer was added

    CGFloat x = originalCenter.x;
    CGPoint newCenter = {.x = x+distance.x, .y = originalCenter.y};
    
    self.slideView.center = newCenter;
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [sender cancelsTouchesInView]; // you may or may not need this - check documentation if unsure
        if (distance.x > 20) { // right
            [self previousTrack];
        } else if (distance.x < -20) { //left
            [self nextTrack];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            self.slideView.center = originalCenter;
        }];
        // Note: if you don't want both axis directions to be triggered (i.e. up and right) you can add a tolerence instead of checking the distance against 0 you could check for greater and less than 50 or 100, etc.
    }
}


- (void)addTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognizer:)];
    [self.slideView addGestureRecognizer:tapRecognizer];
}


- (void)tapRecognizer:(UITapGestureRecognizer *)sender
{
    detailViewController = (NowPlayingDetailViewController *)[[[NSBundle mainBundle] loadNibNamed:@"NowPlayingDetailView" owner:self options:nil] firstObject];
    [detailViewController setSongTitle:self.titleLabel.text artist:self.artistLabel.text albumArt:self.albumArtImageView.image duration:self.duration origin:currentOrigin];
    detailViewController.delegate = self;
    
    [self.parentViewController presentViewController:detailViewController animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
        [detailViewController setCurrentDurationPosition:[durationPositionManager getPlaybackPosition] totalDuration:self.duration];
        [detailViewController setPlaying:self.isPlaying];
    });
}


- (void)setupBackgroundNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterForegroundNotification) name:UIApplicationWillEnterForegroundNotification object:nil];
}


- (void)enterForegroundNotification
{
    [self.delegate nowPlayingBar:self willEnterForeground:YES];
}



#pragma mark - Actions

- (void)nextTrack
{
    [actionTarget performSelectorOnMainThread:nextTrackAction withObject:nil waitUntilDone:NO];
}


- (void)previousTrack
{
    [actionTarget performSelectorOnMainThread:previousTrackAction withObject:nil waitUntilDone:NO];
}


- (IBAction)playPauseButton_pressed:(id)sender
{
    [actionTarget performSelectorOnMainThread:playPauseAction withObject:nil waitUntilDone:NO];
}



#pragma mark - Duration Position Bar Delegate

- (void)playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position sender:(id)sender
{
    if (self.delegate != nil)
        [self.delegate nowPlayingBar:self playbackPositionDidTapToChangeToPosition:position];
}


- (void)playbackPositionDidChangeToPosition:(NSTimeInterval)position duration:(NSTimeInterval)duration sender:(id)sender
{
    if (detailViewController != nil)
        [detailViewController setCurrentDurationPosition:position totalDuration:duration];
}



#pragma mark - Now Playing View Detail Delegate

- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view didTapNextTrack:(BOOL)tapped
{
    [self nextTrack];
}


- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view didTapPlayPauseTrack:(BOOL)tapped
{
    [self playPauseButton_pressed:nil];
}


- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view didTapPreviousTrack:(BOOL)tapped
{
    [self previousTrack];
}


- (void)nowPlayingDetailView:(NowPlayingDetailViewController *)view playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position
{
    [self.delegate nowPlayingBar:self playbackPositionDidTapToChangeToPosition:position];
}

@end
