//
//  ExpensesViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface ExpensesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    uint totalRows;
    uint offset;
    FMDatabase *db;
    UIActivityIndicatorView *loadMoreIndicator;
}

@property (nonatomic, retain) NSMutableArray *listData;

@end

@interface Expense : NSObject {
@public
    int expenseId;
    NSString *note;
    NSNumber *total;
    NSDate *created_at;
    BOOL synced;
}

@end
