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


@interface SoundCloudSearchTableViewController ()

@end

@implementation SoundCloudSearchTableViewController

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
    [SoundCloud performSearchWithQuery:self.searchController.searchBar.text userInfo:@{} callback:^(NSArray *results) {
        
        if (results.count) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                self.searchResults = [NSMutableArray arrayWithArray:results];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            });
        }
        
    }];
}


- (void)setupNavbar
{
    [self setTitle:@"Search"];
    [self.navigationController setNavigationBarHidden:YES];
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
    [self.searchController.searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    
    self.definesPresentationContext = YES;
}


- (void)registerTableViewCellNib
{
    [self.tableView registerNib:[UINib nibWithNibName:TrackTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:TrackTableViewCellIdentifier];
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
}


- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:1.f animations:^
     {
         UIEdgeInsets inset = UIEdgeInsetsMake(108, 0, 0, 0);
         self.tableView.contentInset = inset;
     }];
    
    return YES;
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:1.f animations:^
     {
         UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
         self.tableView.contentInset = inset;
     }];
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
    
    NSDictionary *track = [self.searchResults objectAtIndex:indexPath.row] ? [self.searchResults objectAtIndex:indexPath.row] : @{};
    
    [cell.textLabel setText:track[ktitle]];
    [cell.detailTextLabel setText:track[kuser][kusername]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *track = [self.searchResults objectAtIndex:indexPath.row];
    
    if (_delegate)
        [self.delegate soundCloudSearchTableViewController:self didSelectTrack:track atIndexPath:indexPath];
    
    [self dismissNavigationController];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TrackTableViewCellHeight;
}

@end