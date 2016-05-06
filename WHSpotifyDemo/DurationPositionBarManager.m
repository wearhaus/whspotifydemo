//
//  DurationPositionBarManager.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/8/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "DurationPositionBarManager.h"


@implementation DurationPositionBarManager


#pragma mark - Public

- (instancetype)initWithView:(UIView *)view positionView:(UIView *)positionView touchView:(UIView *)touchView
{
    self = [super init];
    {
        self.progressBarView = view;
        self.progressBarDuration = positionView;
        self.progressBarTouch = touchView;
        self.playing = NO;
        [self addTapGesture];
    }
    return self;
}


- (void)updatePlaybackStatePlaying:(BOOL)play
{
    if (play)
        [self play];
    else
        [self pause];
}


- (void)play
{
    self.playing = YES;
    [self autoAnimate];
}


- (void)pause
{
    self.playing = NO;
    [self setCurrentDurationPosition:[self getPlaybackPosition] totalDuration:self.duration];
}


- (void)stop
{
    self.playing = NO;
    [self updateDurationToPercent:0];
}


- (void)setCurrentDurationPosition:(double)current totalDuration:(double)total
{
    double percent = (current && total) ? current/total : 0.;
    
    [self updateDurationToPercent:percent];
    [self setPosition:current];
    [self setDuration:total];
    
    if (self.isPlaying)
        [self autoAnimateDurationWithPosition:current duration:total];
}


- (NSTimeInterval)getPlaybackPosition
{
    self.playbackPosition += [self secondsSinceAutoPlay];
    startDate = [NSDate date];
    return self.playbackPosition;
}



#pragma mark - Private

- (void)addTapGesture
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
    [self.progressBarTouch addGestureRecognizer:tapRecognizer];
}


- (void)tapRecognized:(UITapGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:sender.view];
    NSTimeInterval newPosition = [self positionWithWidth:point.x];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self setCurrentDurationPosition:[self positionWithWidth:point.x] totalDuration:self.duration];
        [self autoAnimateDurationWithPosition:newPosition duration:self.duration];
        
        if (self.delegate != nil) {
            [self.delegate playbackPositionDidTapToChangeToPosition:newPosition sender:self];
            [self.delegate playbackPositionDidChangeToPosition:newPosition duration:self.duration sender:self];
        }
    }
}


- (void)setPosition:(NSTimeInterval)playbackPosition
{
    self.playbackPosition = playbackPosition;
    startDate = [self isPlaying] ? [NSDate date] : nil;
    [self.delegate playbackPositionDidChangeToPosition:playbackPosition duration:self.duration sender:self];
}


- (NSTimeInterval)secondsSinceAutoPlay
{
    if (startDate == nil)
        return 0;
    
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:startDate];
    startDate = nil;
    
    return seconds;
}


- (void)autoAnimate
{
    [self autoAnimateDurationWithPosition:([self isPlaying] ? [self getPlaybackPosition] : self.playbackPosition) duration:self.duration];
}


- (void)autoAnimateDurationWithPosition:(double)current duration:(double)total
{
    if (current && total) [self setCurrentDurationPosition:current totalDuration:total];
    
    [UIView animateWithDuration:(total-current) delay:0 options:UIViewAnimationOptionCurveLinear animations:^
     {
         self.progressBarDuration.frame = [self progressBarDurationFrameWithWidth:(CGFloat)[self durationWidth]];
     } completion:nil];
    
    [self setDuration:total];
}


- (void)updateDurationToPercent:(double)percent
{
    double currentPositionWidth = [self durationWidth]*percent;
    
    [self.progressBarDuration.layer removeAllAnimations];
    [UIView animateWithDuration:0.0001 animations:^{
        self.progressBarDuration.frame = [self progressBarDurationFrameWithWidth:currentPositionWidth];
    }];
    
    self.playing = NO;
}



#pragma mark - Properties

- (double)durationWidth
{
    return self.progressBarView.frame.size.width;
}


- (CGRect)progressBarDurationFrameWithWidth:(CGFloat)width
{
    CGRect frame = self.progressBarDuration.frame;
    frame.size.width = width;
    return frame;
}


- (NSTimeInterval)positionWithWidth:(double)width
{
    return self.duration*[self percentWithWidth:width];
}


- (double)percentWithWidth:(double)width
{
    return width/self.progressBarView.frame.size.width;
}

@end
