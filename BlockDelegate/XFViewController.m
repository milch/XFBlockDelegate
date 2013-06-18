//
//  XFViewController.m
//  BlockDelegate
//
//  Created by Manu Wallner on 17.06.13.
//  Copyright (c) 2013 Xforge. All rights reserved.
//

#import "XFViewController.h"
#import "XFBlockDelegate.h"

@interface XFViewController ()

@end

@implementation XFViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    XFBlockDelegate *tableDelegate = [XFBlockDelegate delegateWithProtocol:@protocol(UITableViewDataSource)];
    tableDelegate[@"tableView:numberOfRowsInSection:"] = ^(UITableView *tableView, NSInteger section) {
        return 10;
    };
    tableDelegate[@"tableView:cellForRowAtIndexPath:"] = ^(UITableView *tableView, NSIndexPath *indexPath) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Stuff"];
        cell.textLabel.text = @"This class rocks!";
        return cell;
    };
    self.tableView.dataSource = (id)tableDelegate;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

@end
