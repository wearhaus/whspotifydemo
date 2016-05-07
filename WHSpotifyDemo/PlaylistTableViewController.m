//
//  PlaylistTableViewController.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/15/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "PlaylistTableViewController.h"
#import "PlaylistTableViewCell.h"
#import <Spotify/Spotify.h>
#import <Haneke.h>


@interface PlaylistTableViewController ()

@end

@implementation PlaylistTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Playlists"];
    [self registerTableViewCellNib];
    [self setupNavbar];
    
    // TODO: fetch all playlists
    SPTAuth *auth = [SPTAuth defaultInstance];
    [SPTPlaylistList playlistsForUserWithSession:auth.session callback:^(NSError *error, SPTListPage *object) {
        [self loadTableViewWithArray:object.items];
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
}


#pragma mark - Public

- (void)loadTableViewWithArray:(NSArray *)array
{
    self.playlists = array;
    [self.tableView reloadData];
}



#pragma mark - Private

- (void)registerTableViewCellNib
{
    [self.tableView registerNib:[UINib nibWithNibName:PlaylistTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:PlaylistTableViewCellIdentifier];
}


- (void)setupNavbar
{
    [self.navigationController setNavigationBarHidden:NO];
}


- (void)dismissNavigationController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.playlists.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PlaylistTableViewCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlaylistTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaylistTableViewCellIdentifier forIndexPath:indexPath];
    
    SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
    
    [cell initWithPlaylistTitle:playlist.name playlistSubtitle:[NSString stringWithFormat:@"%lu songs", (unsigned long)playlist.trackCount] playlistImageURL:playlist.smallestImage.imageURL];
    
//    [cell.imageView hnk_setImageFromURL:playlist.smallestImage.imageURL];
//    [cell.playlistImage hnk_setImageFromURL:playlist.smallestImage.imageURL];
    // FIXME: get image to display loading from a cache
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    SPTPartialPlaylist *playlist = [self.playlists objectAtIndex:indexPath.row];
    lastSelectedPlaylist = playlist;
    
    MyMusicTableViewController *myMusicViewController = [(MyMusicTableViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"MyMusicTableViewController"] initWithoutAutoload];
    [myMusicViewController setTitle:playlist.name];
    myMusicViewController.delegate = self;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [SPTPlaylistSnapshot playlistWithURI:playlist.uri session:auth.session callback:^(NSError *error, SPTPlaylistSnapshot *object) {
        [myMusicViewController loadTracksWithItems:object.firstTrackPage.items title:playlist.name showsCancelButton:NO userInfo:@{PlaylistURIKey: playlist.uri}];
    }];
    
    // TODO: show loader
    [self.navigationController pushViewController:myMusicViewController animated:YES];
    
//    if (self.delegate != nil)
//        [self.delegate playlistTableView:self didSelectPlaylist:[self.playlists objectAtIndex:indexPath.row]];
//    [self dismissNavigationController];
}



#pragma mark - MyMusicTableViewController Delegate

- (void)myMusicTableViewController:(MyMusicTableViewController *)tableView didSelectTrack:(SPTTrack *)track userInfo:(NSDictionary *)userInfo
{
    if (self.delegate != nil)
        [self.delegate playlistTableView:self didSelectPlaylist:lastSelectedPlaylist userInfo:userInfo];
}

@end
