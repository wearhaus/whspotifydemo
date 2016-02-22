//
//  AccountTableViewController.h
//  WHSpotifyDemo
//
//  Created by Ken Lauguico on 2/19/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum {
    AccountTableViewCellLogout,
    AccountTableViewCellCount
}AccountTableViewCell;

@protocol AccountTableViewControllerDelegate;

@interface AccountTableViewController : UITableViewController

@property (weak) NSObject<AccountTableViewControllerDelegate> *delegate;

@end

@protocol AccountTableViewControllerDelegate <NSObject>
- (void)accountTableView:(AccountTableViewController *)tableView didSelectLogout:(BOOL)didSelectLogout;
@end