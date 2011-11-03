//
//  ExpensesViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "AddExpenseViewController.h"

@interface ExpensesViewController : UIViewController
		<AddExpenseViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    uint totalRows;
    uint offset;
}

@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)didCancel:(AddExpenseViewController *)controller;
- (void)didSave:(AddExpenseViewController *)controller;

@end

