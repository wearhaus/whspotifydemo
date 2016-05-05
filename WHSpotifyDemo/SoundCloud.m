//
//  SoundCloud.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 4/25/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SoundCloud.h"
#import "SoundCloud+Helper.h"
#import "kSoundcloud.h"
#import "NSArray+stringify.h"
#import "NSDictionary+QueryStringBuilder.h"
#import "AVPlayerItem+Helper.h"
#import <AFNetworking.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>


#define SC_HOST             @"http://api.soundcloud.com"

#define SC_CLIENT_ID        @"c5791e23c5dbd5b726b7cc7dc409da5b"
#define SC_CLIENT_SECRET    @"86ed937c98c7c2795a747168e9521a35"

@implementation SoundCloud

- (void)dealloc
{
    [self removeObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Public
#pragma mark Player

+ (instancetype)player
{
    static SoundCloud *_player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _player = [[self alloc] _initAVPlayer];
    });
    
    return _player;
}


- (instancetype)_initAVPlayer
{
    self = [super init];
    
    self.avPlayer = [[AVPlayer alloc] init];
    [self avPlayer_allowBluetooth];
    
    return self;
}


- (void)_setIsPlaying:(BOOL)isPlaying
{
    if (isPlaying)
    {
        [_avPlayer play];
        self.playing = YES;
    }
    else
    {
        [_avPlayer pause];
        self.playing = NO;
    }
}


- (void)_loadAndPlayTrack:(NSDictionary *)track
{
    currentTrack = [NSDictionary dictionaryWithDictionary:track];
    [self _loadAndPlayURLString:track[kstream_url]];
}


- (void)_loadAndPlayURLString:(NSString *)url
{
    [self _loadAndPlayURL:[NSURL URLWithString:url]];
}


- (void)_loadAndPlayURL:(NSURL *)url
{
    NSURL *authenticatedURL = [NSURL URLWithString:[@[url.absoluteString, [self authenticate]] stringify]];
    
    if (item) [item removeObserver:self forKeyPath:@"status"];
    
    item = [AVPlayerItem playerItemWithURL:authenticatedURL];
    [self observePlayerChanges];
    
    _avPlayer = [AVPlayer playerWithPlayerItem:item];
    [self _setIsPlaying:YES];
}


- (NSDictionary *)_getCurrentTrack
{
    return currentTrack;
}


- (NSNumber *)currentPlaybackPosition
{
    return [self.avPlayer.currentItem _seconds];
}


- (NSNumber *)currentTrackDuration
{
    return currentTrack[kduration];
}


#pragma mark Helper

- (void)observePlayerChanges
{
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial context:nil];
    [self.delegate addObserver:self forKeyPath:@"hash" options:NSKeyValueObservingOptionInitial context:nil];
    
    // NSNotification approach
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPlayToEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeJumped:) name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToPlayToEndTime:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
}


- (void)didPlayToEnd
{
    if (self.delegate != nil)
    {
        [self _setIsPlaying:NO];
        [self.delegate soundCloud:self didChangePlaybackStatus:NO];
    }
}


- (void)timeJumped:(NSNotification *)notification
{
    AVPlayerItem *playerItem = notification.object;
    NSLog(@"\n\n[time jumped] %@\n\n", [playerItem _seconds]);
    
    if (self.delegate != nil)
        [self.delegate soundCloud:self didSeekToOffset:[playerItem _seconds].doubleValue];
}


- (void)failedToPlayToEndTime:(NSNotification *)notification
{
    NSLog(@"\n\n[failed to play to end] %@\n\n", notification.userInfo);
    
    if (self.delegate != nil)
        [self.delegate soundCloud:self didFailToPlayTrack:nil];
}


- (void)playbackStalled:(NSNotification *)notification
{
    NSLog(@"\n\n[playback stalled] %@\n\n", notification.userInfo);
    
    if (self.delegate != nil)
        [self.delegate soundCloud:self didFailToPlayTrack:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == item && [keyPath isEqualToString:@"status"])
    {
        switch (item.status)
        {
            case AVPlayerStatusReadyToPlay:
            {
                if (_delegate)
                    [self.delegate soundCloud:self didChangePlaybackStatus:[self isPlaying]];
                break;
            }
                
            case AVPlayerStatusFailed:
            {
                if (_delegate)
                    [self.delegate soundCloud:self didChangePlaybackStatus:NO];
                break;
            }
                
            case AVPlayerStatusUnknown:
            {
                break;
            }
        }
    }
    
    if (object == self.delegate)
    {
        if (!self.delegate)
            [self removeObservers];
    }
}

- (void)removeObservers
{
    [item removeObserver:self forKeyPath:@"status"];
    [self.delegate removeObserver:self forKeyPath:@"hash"];
}


#pragma mark HTTP

+ (void)getUser_userInfo:(NSDictionary *)dict success:(void (^)(NSDictionary *responseObject))succcessBlock fail:(void (^)(BOOL finished))failBlock
{
    
}


+ (void)getTrack_userInfo:(NSDictionary *)dict success:(void (^)(NSDictionary *responseObject))succcessBlock fail:(void (^)(BOOL finished))failBlock
{
    [self request:[self track:@"206920024"] fromServer:SC_HOST withParams:nil success:^(NSDictionary *dict) {
        
        // TODO: put track URL in response
        // TODO: commented and logged instructions on how to load track
        // Reference: http://stackoverflow.com/questions/13111391/soundcloud-api-ios-no-sharing-only-listening
        //            https://developers.soundcloud.com/docs/api/reference#tracks

        if (succcessBlock) succcessBlock(dict);
        
    } fail:^(BOOL failed) {
        
        if (failBlock) failBlock(YES);
        
    }];
}


+ (void)performSearchWithQuery:(NSString *)searchQuery userInfo:(NSDictionary *)dict callback:(void (^)(NSArray *))block
{
    [self request:[self searchForTrack:searchQuery] fromServer:SC_HOST withParams:nil success:^(id array) {
        
        if (block) block(array);
        
    } fail:^(BOOL finished) {
        
        NSLog(@"\n\n[debug] %@\n\n", @"Failed search.");
        
    }];
}



#pragma mark - Private

+ (void)request:(NSString *)command fromServer:(NSString *)server withParams:(NSDictionary *)dict success:(void (^)(id))succcessBlock fail:(void (^)(BOOL))failBlock;
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *commandURL = [NSURL URLWithString:[@[server,command] stringify]];
    
    NSURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:commandURL.
                             absoluteString parameters:dict error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse *response, id responseObject, NSError *error)
    {
        if (error)
        {
            if (failBlock) failBlock(YES);
            NSLog(@"\n\n[error] %@\n\n", error);
        }
        else
        {
            // TODO: have another check to make sure results are correct
            if (succcessBlock) succcessBlock(responseObject);
        }
    }];
    
    [dataTask resume];
}


#pragma mark Helper methods

+ (NSString *)track:(NSString *)trackID
{
    return [@[ktracks,@"/",trackID,[self authenticate]]
            stringify];
}


+ (NSString *)searchForTrack:(NSString *)query
{
    NSDictionary *params = @{
                             kq:            query,
                             kclient_id:    SC_CLIENT_ID
                             };
    
    return [@[ktracks,@"?",params.queryString]
            stringify];
}


+ (NSString *)authenticate
{
    return [@[@"?",kclient_id,@"=",SC_CLIENT_ID]
            stringify];
}
                                

- (NSString *)authenticate
{
    return [@[@"?",kclient_id,@"=",SC_CLIENT_ID]
    stringify];
}

- (void)avPlayer_allowBluetooth
{
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    withOptions:AVAudioSessionCategoryOptionAllowBluetooth
                    error:&setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
}

@end
