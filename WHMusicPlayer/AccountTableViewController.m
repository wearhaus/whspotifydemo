//
//  AccountTableViewController.m
//  WHMusicPlayer
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "AccountTableViewController.h"

@interface AccountTableViewController ()

@end

@implementation AccountTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Account"];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return AccountTableViewCellCount;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch ((AccountTableViewCell)indexPath.row)
    {
        case AccountTableViewCellLogout:
        {
            [self.delegate accountTableView:self didSelectLogout:YES];
            break;
        }
            
        default:
            break;
    }
}

@end
