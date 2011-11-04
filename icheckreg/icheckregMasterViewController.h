//
//  icheckregMasterViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddExpenseViewController.h"

@class icheckregDetailViewController;

@interface icheckregMasterViewController : UITableViewController
		<AddExpenseViewControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
   
}

@property (nonatomic, retain) NSManagedObjectContext *context;

- (IBAction)settings:(id)sender;
- (IBAction)addExpense;
- (void)didSave: (AddExpenseViewController *)controller;

@end
