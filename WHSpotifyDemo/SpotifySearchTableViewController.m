//
//  SpotifySearchTableViewController.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 1/27/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "SpotifySearchTableViewController.h"
#import "SPTSearch+WebAPI.h"
#import "TrackTableViewCell.h"
#import <Spotify/Spotify.h>
#import "SoundCloud.h"
#import "kSoundcloud.h"


@interface SpotifySearchTableViewController ()
{
    NSTimer *searchDelay;
}
@end

@implementation SpotifySearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupNavbar];
    [self initSearchController];
    [self registerTableViewCellNib];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)dismissNavigationController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Private

- (void)beginSearch
{
    [SoundCloud performSearchWithQuery:self.searchController.searchBar.text userInfo:@{} callback:^(id responseObject) {
        
        [[SoundCloud player] _loadAndPlayURLString:responseObject[0][kstream_url]];
        
    }];
    
//    [SPTSearch performSearchWithQuery:self.searchController.searchBar.text queryType:SPTQueryTypeTrack callback:^(NSError *error, SPTListPage *object) {
//        if (!error) {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                self.searchResults = [NSMutableArray arrayWithArray:object.items];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.tableView reloadData];
//                });
//            });
//        }
//    }];
}


- (void)setupNavbar
{
    [self setTitle:@"Search"];
    [self.navigationController setNavigationBarHidden:NO];
}


- (void)initSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    // init searchBar
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    [self.searchController.searchBar setShowsCancelButton:NO];
    
    self.definesPresentationContext = YES;
}


- (void)registerTableViewCellNib
{
    [self.tableView registerNib:[UINib nibWithNibName:TrackTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:TrackTableViewCellIdentifier];
}



#pragma mark - Search Bar Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
//    if (searchController.searchBar.text.length != 0)
//        [self performSelectorOnMainThread:@selector(beginSearch) withObject:nil waitUntilDone:NO];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
    [self beginSearch];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TrackTableViewCellIdentifier forIndexPath:indexPath];
    
    SPTTrack *track = [self.searchResults objectAtIndex:indexPath.row];
    SPTPartialArtist *artist = [track.artists objectAtIndex:0];
    
    [cell.textLabel setText:track.name];
    [cell.detailTextLabel setText:artist.name];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTTrack *track = [self.searchResults objectAtIndex:indexPath.row];
    
    if (_delegate)
        [self.delegate spotifySearchTableViewController:self didSelectTrack:track atIndexPath:indexPath];
    
    [self dismissNavigationController];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TrackTableViewCellHeight;
}

@end