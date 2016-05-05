//
//  SearchTabsNavigationViewController.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 5/5/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "SearchTabsNavigationViewController.h"
#import "SpotifySearchTableViewController.h"
#import "SoundCloudSearchTableViewController.h"


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
    self.navigationItem.titleView = servicesSegmentedControl;
    
    // TODO: find out whether center or custom/math is needed to add subview
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
        [self hackyFixForTableView:self.spotifySearchTableViewController];
    }
    
    return self.spotifySearchTableViewController;
}


- (SoundCloudSearchTableViewController *)getSoundCloudService
{
    if (!self.soundCloudSearchTableViewController)
    {
        self.soundCloudSearchTableViewController = [[SoundCloudSearchTableViewController alloc] init];
        [self hackyFixForTableView:self.soundCloudSearchTableViewController];
    }
    
    return self.soundCloudSearchTableViewController;
}


- (void)hackyFixForTableView:(UITableViewController *)tableViewController
{
//    tableViewController.automaticallyAdjustsScrollViewInsets = NO;
//    tableViewController.tableView.contentInset = UIEdgeInsetsZero;
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
