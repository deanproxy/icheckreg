//
//  ExpensesViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpensesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    sqlite3 *database;
}

@property (nonatomic, retain) NSMutableArray *listData;

@end

@interface Expense : NSObject {
@public
    int expenseId;
    NSString *note;
    NSNumber *total;
    NSString *created_at;
    BOOL synced;
}

@end
