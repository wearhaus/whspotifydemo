//
//  DurationPositionBarManager.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/8/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DurationPositionBarManagerDelegate;

/**
 *  A class that handles the functionality and updating of the duration position
 *  views.
 */
@interface DurationPositionBarManager : NSObject
{
    NSDate *startDate;
}

@property (assign, nonatomic, getter=isPlaying) BOOL playing;
@property (assign, nonatomic) UIView *progressBarView;
@property (assign, nonatomic) UIView *progressBarDuration;
@property (assign, nonatomic) UIView *progressBarTouch;
@property (nonatomic) NSTimeInterval playbackPosition;
@property (nonatomic) NSTimeInterval duration;
@property (weak) NSObject<DurationPositionBarManagerDelegate> *delegate;

- (instancetype)initWithView:(UIView *)view positionView:(UIView *)positionView touchView:(UIView *)touchView;
- (void)setCurrentDurationPosition:(double)current totalDuration:(double)total;
- (void)updatePlaybackStatePlaying:(BOOL)play;
- (void)play;
- (void)pause;
- (void)stop;

- (double)durationWidth;
- (CGRect)progressBarDurationFrameWithWidth:(CGFloat)width;
- (NSTimeInterval)positionWithWidth:(double)width;
- (double)percentWithWidth:(double)width;
- (NSTimeInterval)getPlaybackPosition;

- (void)setPosition:(NSTimeInterval)playbackPosition;

@end


@protocol DurationPositionBarManagerDelegate <NSObject>
@optional
/**
 *  Fires when the user changes the position on the now playing bar.
 */
- (void)playbackPositionDidTapToChangeToPosition:(NSTimeInterval)position sender:(id)sender;
/**
 *  Fires when a change happens in the playback position.
 */
- (void)playbackPositionDidChangeToPosition:(NSTimeInterval)position duration:(NSTimeInterval)duration sender:(id)sender;
@end