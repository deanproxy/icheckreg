//
//  AddExpenseViewController.h
//  icheckreg
//
//  Created by Dean Jones on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AddExpenseViewController;

@protocol AddExpenseViewControllerDelegate <NSObject>

- (void)didCancel: (AddExpenseViewController *)controller;
- (void)didSave: (AddExpenseViewController *)controller;

@end

@interface AddExpenseViewController : UITableViewController {
    @public
    BOOL isDeposit;
    uint expenseId;
}

@property (nonatomic, weak) id <AddExpenseViewControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UITextField *description;
@property (strong, nonatomic) IBOutlet UITextField *amount;
@property (strong, nonatomic) IBOutlet UITableViewCell *deposit;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end
