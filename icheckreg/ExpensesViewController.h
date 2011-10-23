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

@end

@interface Expense : NSObject {

}

@property(nonatomic, retain) NSString *note;
@property(nonatomic, retain) NSString *date;
@property(nonatomic) float total;

- (id)initWithString: (NSString *)newNote date:(NSString *)newDate total:(float)newTotal;

@end
