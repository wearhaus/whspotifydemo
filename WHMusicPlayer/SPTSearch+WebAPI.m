//
//  SPTSearch+WebAPI.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/3/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "SPTSearch+WebAPI.h"

@implementation SPTSearch (WebAPI)

+ (void)performSearchWithQuery:(NSString *)searchQuery queryType:(SPTSearchQueryType)searchQueryType callback:(SPTRequestCallback)block
{
    // TODO: Limit for request rates and timeouts
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@&type=%@", searchQuery, [self searchQueryTypeString:searchQueryType]]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (error) {
            block(error,nil);
        }
        else {
            NSError *err=nil;
            NSDictionary *jsonResult = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
            if(!err) {
                NSError *er=nil;
                SPTListPage *object = [self searchResultsFromDecodedJSON:jsonResult queryType:searchQueryType error:&er];
                if (!er || object.items.count) {
                    block(nil,object);
                }
                else {
                    block(er,nil);
                }
                block(error,object);
            }
            else {
                block(err,nil);
            }
        }
        
    }];
}


+ (NSString *)searchQueryTypeString:(SPTSearchQueryType)searchQueryType
{
    switch (searchQueryType) {
        case SPTQueryTypeTrack:
            return @"track";
            break;
            
        case SPTQueryTypeArtist:
            return @"artist";
            break;
            
        case SPTQueryTypeAlbum:
            return @"album";
            break;
            
        case SPTQueryTypePlaylist:
            return @"playlist";
            break;
            
        default:
            return @"track,artist,album,playlist";
            break;
    }
}

@end
