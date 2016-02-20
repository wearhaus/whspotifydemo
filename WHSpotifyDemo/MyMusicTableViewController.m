//
//  MyMusicTableViewController.m
//  Simple Track Playback
//
//  Created by Ken Lauguico on 2/17/16.
//  Copyright © 2016 Your Company. All rights reserved.
//

#import "MyMusicTableViewController.h"
#import "TrackTableViewCell.h"
#import <Spotify/Spotify.h>


@interface MyMusicTableViewController ()
{
    BOOL noAutoload;
}
@end

@implementation MyMusicTableViewController

- (instancetype)initWithoutAutoload
{
    self = [super init];
    {
        noAutoload = YES;
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerTableViewCellNib];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 100, 0);
    
    if (noAutoload)
        return;
    
    [self setTitle:@"My Music"];
    SPTAuth *auth = [SPTAuth defaultInstance];
    [SPTYourMusic savedTracksForUserWithAccessToken:auth.session.accessToken callback:^(NSError *error, SPTListPage *object) {
        [self loadTracksWithItems:object.items title:@"My Music" showsCancelButton:NO userInfo:nil];
    }];
}


#pragma mark - Public

- (void)loadTracksWithItems:(NSArray *)tracks title:(NSString *)title showsCancelButton:(BOOL)showsCancel userInfo:(NSDictionary *)userInfo
{
    [self setTitle:title];
    [self loadTableViewWithArray:tracks];
    
    if (showsCancel)
        [self setupNavbarCancelButton];
    
    if ([userInfo objectForKey:PlaylistURIKey])
        playlistURI = [userInfo objectForKey:PlaylistURIKey];
}



#pragma mark - Private

- (void)loadTableViewWithArray:(NSArray *)array
{
    self.tracks = array;
    [self.tableView reloadData];
}


- (void)registerTableViewCellNib
{
    [self.tableView registerNib:[UINib nibWithNibName:TrackTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:TrackTableViewCellIdentifier];
}


- (void)setupNavbarCancelButton
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismissNavigationController)];
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
    return self.tracks.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TrackTableViewCellHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TrackTableViewCellIdentifier forIndexPath:indexPath];
    
    SPTTrack *track = [self.tracks objectAtIndex:indexPath.row];
    SPTPartialArtist *artist = [track.artists objectAtIndex:0];
    
    [cell.textLabel setText:track.name];
    [cell.detailTextLabel setText:artist.name];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.delegate != nil)
    {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:@{IndexPathKey: indexPath}];
        
        if (playlistURI != nil)
            [userInfo setObject:playlistURI forKey:PlaylistURIKey];
        
        [self.delegate myMusicTableViewController:self didSelectTrack:[self.tracks objectAtIndex:indexPath.row] userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self dismissNavigationController];
}

@end
