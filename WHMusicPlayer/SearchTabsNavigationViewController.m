//
//  SearchTabsNavigationViewController.m
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 5/5/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SearchTabsNavigationViewController.h"


@interface SearchTabsNavigationViewController ()

@end


@implementation SearchTabsNavigationViewController


- (instancetype)init
{
    self = [super init];
    {
        (void)[self getSpotifyService];
        (void)[self getSoundCloudService];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initServicesSegmentedControl];
    [self listenForKeyboardNotifications];
}


- (void)initServicesSegmentedControl
{
    NSArray *services = @[
                          @"Spotify",
                          @"SoundCloud"
                          ];
    
    UISegmentedControl *servicesSegmentedControl = [[UISegmentedControl alloc] initWithItems:services];
    servicesSegmentedControl.frame = CGRectMake(60, 250,200, 30);
    servicesSegmentedControl.selectedSegmentIndex = 0;
    
    [servicesSegmentedControl addTarget:self action:@selector(segmentedControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self segmentedControlChanged:servicesSegmentedControl];
    [self.navigationItem setTitleView:servicesSegmentedControl];
    
    // TODO: find out whether center or custom/math is needed to add subview
}



#pragma mark - SpotifySearchTableViewControllerDelegate

- (void)spotifySearchTableViewController:(SpotifySearchTableViewController *)tableView didLoadView:(BOOL)loaded
{
//    [self hackilyAddSearchBar];
}


#pragma mark - Helper

- (void)segmentedControlChanged:(UISegmentedControl *)sender
{
    switch ((SearchServices)sender.selectedSegmentIndex)
    {
        case SearchServiceSpotify:
        {
            [self setViewControllers:@[[self getSpotifyService]]];
            break;
        }
            
        case SearchServiceSoundCloud:
        {
            [self setViewControllers:@[[self getSoundCloudService]]];
            break;
        }
    }
}


- (SpotifySearchTableViewController *)getSpotifyService
{
    if (!self.spotifySearchTableViewController)
    {
        self.spotifySearchTableViewController = [[SpotifySearchTableViewController alloc] init];
        self.spotifySearchTableViewController.delegate = self;
        
        if (self.soundCloudSearchTableViewController.searchController)
            self.spotifySearchTableViewController.searchController = self.soundCloudSearchTableViewController.searchController;
    }
    
    // update search text
    if (self.soundCloudSearchTableViewController.searchController)
        self.spotifySearchTableViewController.searchController.searchBar.text
        = self.soundCloudSearchTableViewController.searchController.searchBar.text;
    
    return self.spotifySearchTableViewController;
}


- (SoundCloudSearchTableViewController *)getSoundCloudService
{
    if (!self.soundCloudSearchTableViewController)
    {
        self.soundCloudSearchTableViewController = [[SoundCloudSearchTableViewController alloc] init];
        self.soundCloudSearchTableViewController.searchController = self.spotifySearchTableViewController.searchController;
    }
    
    // update search text
    self.soundCloudSearchTableViewController.searchController.searchBar.text
    = self.spotifySearchTableViewController.searchController.searchBar.text;
    
    return self.soundCloudSearchTableViewController;
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





- (void)hackyFixForTableView:(UITableViewController *)tableViewController
{
    tableViewController.tableView.contentInset = UIEdgeInsetsMake(.01, 0, 0, 0);
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
