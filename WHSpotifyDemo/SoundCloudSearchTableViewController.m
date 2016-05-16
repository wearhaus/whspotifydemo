//
//  SoundCloudSearchTableViewController.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 4/27/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SoundCloudSearchTableViewController.h"
#import "TrackTableViewCell.h"
#import "SoundCloud.h"
#import "kSoundcloud.h"
#import "kMusicServices.h"
#import "PlaybackQueue.h"
#import "NSDictionary+TrackHelper.h"


@interface SoundCloudSearchTableViewController () <UISearchBarDelegate>

@end


@implementation SoundCloudSearchTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSearchController];
    [self registerTableViewCellNib];
    [self listenForKeyboardNotifications];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
}


- (void)dismissNavigationController
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - Private

- (void)beginSearch
{
    [SoundCloud performSearchWithQuery:self.searchController.searchBar.text userInfo:@{} callback:^(NSArray *results) {
        
        if (results.count) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
            {
                self.searchResults = [NSMutableArray arrayWithArray:results];
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    [self.tableView reloadData];
                });
            });
        }
        
    }];
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
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
}


- (void)showNavbar
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    NSString *lastSearch = self.searchController.searchBar.text;
    self.searchController.active = NO;
    self.searchController.searchBar.text = lastSearch;
}



#pragma mark - Search Bar Delegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchController.searchBar.text.length != 0)
        [self performSelectorOnMainThread:@selector(beginSearch) withObject:nil waitUntilDone:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
    [self beginSearch];
    [self showNavbar];
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
    TrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TrackTableViewCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *track = [self.searchResults objectAtIndex:indexPath.row] ? [self.searchResults objectAtIndex:indexPath.row] : @{};
    
    [cell.textLabel setText:track[ktitle]];
    [cell.detailTextLabel setText:track[kuser][kusername]];
    [cell addLongTapToQueueForTrack:track];
    
    [cell.musicServiceColorLabel setBackgroundColor:[track isPlaying] ? COLOR_SOUNDCLOUD : [UIColor whiteColor]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *track = [self.searchResults objectAtIndex:indexPath.row];
    
    if (_delegate)
        [self.delegate soundCloudSearchTableViewController:self didSelectTrack:track atIndexPath:indexPath];
    
    [self dismissNavigationController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // indicate current track is playing
    [UIView animateWithDuration:0.4f animations:^
    {
        TrackTableViewCell *trackCell = (TrackTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        [trackCell.musicServiceColorLabel setBackgroundColor:COLOR_SOUNDCLOUD];
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TrackTableViewCellHeight;
}

@end