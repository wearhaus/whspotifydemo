//
//  LoginViewController.m
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "LoginViewController.h"
#import "SpotifyConfig.h"


@interface LoginViewController () <SPTAuthViewDelegate>
{
    BOOL firstLoad;
}
@end


@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionUpdatedNotification:) name:@"sessionUpdated" object:nil];
    firstLoad = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated {
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    // Check if we have a token at all
    if (auth.session == nil) {
        return;
    }
    
    // Check if it's still valid
    if ([auth.session isValid] && firstLoad) {
        // It's still valid, show the player.
        [self showMain];
        return;
    }
    
    // Oh noes, the token has expired, if we have a token refresh service set up, we'll call tat one.
    if (auth.hasTokenRefreshService) {
        [self renewTokenAndShowPlayer];
        return;
    }
    
    // Else, just show login dialog
}



#pragma mark - Private

- (void)openLoginPage
{
    self.authViewController = [SPTAuthViewController authenticationViewController];
    self.authViewController.delegate = self;
    self.authViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.authViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    self.definesPresentationContext = YES;
    
    [self presentViewController:self.authViewController animated:NO completion:nil];
}


- (void)renewTokenAndShowPlayer
{
    SPTAuth *auth = [SPTAuth defaultInstance];
    
    [auth renewSession:auth.session callback:^(NSError *error, SPTSession *session) {
        auth.session = session;
        
        if (error) {
            NSLog(@"*** Error renewing session: %@", error);
            return;
        }
        
        [self showMain];
    }];
}


- (void)showMain
{
    firstLoad = NO;
    [self performSegueWithIdentifier:@"ShowTabView" sender:nil];
}


- (void)sessionUpdatedNotification:(NSNotification *)notification
{
    if(self.navigationController.topViewController == self) {
        SPTAuth *auth = [SPTAuth defaultInstance];
        if (auth.session && [auth.session isValid]) {
            [self performSegueWithIdentifier:@"ShowTabView" sender:nil];
        }
    }
}



#pragma mark - Action

- (IBAction)loginButton_clicked:(id)sender
{
    [self openLoginPage];
}



#pragma mark - SPTAuthView Delegate

- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didFailToLogin:(NSError *)error
{
    NSLog(@"*** Failed to log in: %@", error);
}


- (void)authenticationViewController:(SPTAuthViewController *)viewcontroller didLoginWithSession:(SPTSession *)session
{
    [self showMain];
}


- (void)authenticationViewControllerDidCancelLogin:(SPTAuthViewController *)authenticationViewController
{
}

@end
