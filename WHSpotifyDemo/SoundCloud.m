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
#import <AFNetworking.h>


#define SC_HOST             @"http://api.soundcloud.com"

#define SC_CLIENT_ID        @"c5791e23c5dbd5b726b7cc7dc409da5b"
#define SC_CLIENT_SECRET    @"86ed937c98c7c2795a747168e9521a35"

@implementation SoundCloud

#pragma mark - Public

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



#pragma mark - Private

+ (void)request:(NSString *)command fromServer:(NSString *)server withParams:(NSDictionary *)dict success:(void (^)(NSDictionary *))succcessBlock fail:(void (^)(BOOL))failBlock;
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
    return [@[ktracks,@"/",trackID, [self authenticate]]
            stringify];
}


+ (NSString *)authenticate
{
    return [@[@"?",kclient_id,@"=",SC_CLIENT_ID]
            stringify];
}

@end
