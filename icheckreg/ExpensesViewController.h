//
//  ExpensesViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpensesViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {

}

@property (nonatomic, retain) NSArray *listData;
@property (nonatomic, retain) NSManagedObjectContext *context;

@end

