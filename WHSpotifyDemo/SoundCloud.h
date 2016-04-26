//
//  SoundCloud.h
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 4/25/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AVPlayer;
@interface SoundCloud : NSObject

@property(strong, nonatomic) AVPlayer *avPlayer;

/**
 *  Init a singleton of the location manager.
 */
+ (instancetype)player;

- (void)_loadAndPlayURLString:(NSString *)url;

+ (void)getUser_userInfo:(NSDictionary *)dict success:(void (^)(NSDictionary *responseObject))succcessBlock fail:(void (^)(BOOL finished))failBlock;
+ (void)getTrack_userInfo:(NSDictionary *)dict success:(void (^)(NSDictionary *responseObject))succcessBlock fail:(void (^)(BOOL finished))failBlock;
+ (void)performSearchWithQuery:(NSString *)searchQuery userInfo:(NSDictionary *)dict callback:(void (^)(NSDictionary *responseObject))block;

@end
