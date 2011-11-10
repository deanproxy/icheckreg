//
//  ExpensesViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddExpenseViewController.h"

@interface ExpensesViewController : UIViewController
		<AddExpenseViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    uint totalRows;
    uint offset;
}

@property (nonatomic, retain) NSMutableArray *listData;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

- (void)didSave:(AddExpenseViewController *)controller;
- (IBAction)addExpense;

@end

