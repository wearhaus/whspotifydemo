//
//  SPTSearch+WebAPI.h
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/3/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import <Spotify/Spotify.h>

@interface SPTSearch (WebAPI)

/** Create a request for searching with a given query. No access token needed.
 
 @param searchQuery The query to pass to the search.
 @param searchQueryType The type of search to do.
 @param block The block to be called when the operation is complete. The block will pass an `SPTListPage` containing results on success, otherwise an error.
 */
+ (void)performSearchWithQuery:(NSString *)searchQuery queryType:(SPTSearchQueryType)searchQueryType callback:(SPTRequestCallback)block;

@end
