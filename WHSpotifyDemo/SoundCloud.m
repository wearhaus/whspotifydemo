//
//  SoundCloud.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 4/25/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SoundCloud.h"
#import "kSoundcloud.h"
#import "NSArray+stringify.h"
#import "NSDictionary+QueryStringBuilder.h"
#import <AFNetworking.h>
#import <AVFoundation/AVPlayer.h>
#import <AVFoundation/AVPlayerItem.h>


#define SC_HOST             @"http://api.soundcloud.com"

#define SC_CLIENT_ID        @"c5791e23c5dbd5b726b7cc7dc409da5b"
#define SC_CLIENT_SECRET    @"86ed937c98c7c2795a747168e9521a35"

@implementation SoundCloud

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
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:authenticatedURL];
    _avPlayer = [AVPlayer playerWithPlayerItem:item];
    [_avPlayer play];
}


- (NSDictionary *)_getCurrentTrack
{
    return currentTrack;
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
        
        NSLog(@"%@",dict[kstream_url]);
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
    
    
    
    NSLog(@"\n\n[request] %@\n\n[json] %@\n\n", commandURL, dict);
    
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
            NSLog(@"\n\n[response] %@ %@\n\n", response, responseObject);
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

@end
