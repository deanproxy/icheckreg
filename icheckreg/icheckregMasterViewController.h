//
//  icheckregMasterViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanAddExpense.h"

@class icheckregDetailViewController;

@interface icheckregMasterViewController : UITableViewController <CanAddExpense, UITableViewDelegate, UITableViewDataSource> {
   
}

@property (nonatomic, retain) NSManagedObjectContext *context;

- (IBAction)settings:(id)sender;

@end
