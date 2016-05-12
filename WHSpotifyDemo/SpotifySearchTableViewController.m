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
#import "SoundCloud.h"
#import "kSoundcloud.h"
#import "SPTPartialTrack+Helper.h"
#import "PlaybackQueue.h"
#import "kMusicServices.h"
#import <Spotify/Spotify.h>


@interface SpotifySearchTableViewController () <UISearchBarDelegate>
{
    NSTimer *searchDelay;
}
@end

@implementation SpotifySearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSearchController];
    [self registerTableViewCellNib];
    [self listenForKeyboardNotifications];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
}


- (void)viewWillAppear:(BOOL)animated
{
    self.searchController.searchBar.delegate = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableView.tableHeaderView = self.searchController.searchBar;
        [self.searchController.searchBar sizeToFit];
    });
}


- (void)dismissNavigationController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Private

- (void)beginSearch
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    
        [SPTSearch performSearchWithQuery:self.searchController.searchBar.text queryType:SPTQueryTypeTrack callback:^(NSError *error, SPTListPage *object) {
            if (!error) {
                self.searchResults = [NSMutableArray arrayWithArray:object.items];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }];
        
    });
}


- (void)initSearchController
{
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    // init searchBar
    [self.searchController.searchBar setShowsCancelButton:NO animated:NO];
    [self.searchController.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    [self.searchController.searchBar sizeToFit];
    
    self.definesPresentationContext = YES;
}


- (void)registerTableViewCellNib
{
    [self.tableView registerNib:[UINib nibWithNibName:TrackTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:TrackTableViewCellIdentifier];
}


#pragma mark Helper

- (void)longTapToQueue:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@"gestureRecognizer= %@",gestureRecognizer);
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan)
    {
        NSLog(@"longTap began");
        [[PlaybackQueue manager] _playLater:@[self.searchResults[gestureRecognizer.view.tag]]];
    }
}


- (void)listenForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideNavbar)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNavbar)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}


- (void)hideNavbar
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)showNavbar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}



#pragma mark - Search Bar Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchController.searchBar.text.length != 0)
        [self performSelectorOnMainThread:@selector(beginSearch) withObject:nil waitUntilDone:NO];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
    [self beginSearch];
    self.searchController.active = NO;
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:NO];
    
//    [UIView animateWithDuration:.8f animations:^
//     {
//         UIEdgeInsets inset = UIEdgeInsetsMake(108, 0, 0, 0);
//         self.tableView.contentInset = inset;
//     }];
    
    return YES;
}


#pragma mark Helper

- (CGFloat)getNavigationBarHeight
{
    return [(UINavigationController *)self.parentViewController navigationItem].titleView.frame.size.height/2 + 5;
}



#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchController.searchBar resignFirstResponder];
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
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapToQueue:)];
    [cell addGestureRecognizer:longPressGesture];
    longPressGesture.view.tag = indexPath.row;
    
    [((TrackTableViewCell *)cell).musicServiceColorLabel setBackgroundColor:[track isPlaying] ? COLOR_SPOTIFY : [UIColor whiteColor]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SPTTrack *track = [self.searchResults objectAtIndex:indexPath.row];
    
    if (_delegate)
        [self.delegate spotifySearchTableViewController:self didSelectTrack:track atIndexPath:indexPath];
    
    [self dismissNavigationController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // indicate current track is playing
    [UIView animateWithDuration:0.4f animations:^
     {
         TrackTableViewCell *trackCell = (TrackTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
         [trackCell.musicServiceColorLabel setBackgroundColor:COLOR_SPOTIFY];
         
         [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
     }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TrackTableViewCellHeight;
}

@end