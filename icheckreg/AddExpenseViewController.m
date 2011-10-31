//
//  AddExpenseViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddExpenseViewController.h"
#import "icheckregAppDelegate.h"
#import "CanAddExpense.h"

@implementation AddExpenseViewController

@synthesize delegate;
@synthesize description;
@synthesize amount;
@synthesize deposit;

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    float total = 0.0;
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = delegate.db;
    NSString *totalQuery = @"update total set total = ?";
    FMResultSet *result = [db executeQuery:@"select total from total"]; 
    if ([result next]) {
        total = [result doubleForColumnIndex:0];
    } else {
        /* If we couldn't get anything from the total DB, we should insert */
        totalQuery = @"insert into total (total) values(?)";
    }
    float expenseAmount = amount.text.floatValue;
    if (!self->isDeposit) {
        expenseAmount = -expenseAmount;
    }
    NSString *query = @"insert into expenses (note, total) values (?, ?)";
    [db executeUpdate:query, self.description.text, [[NSNumber alloc] initWithFloat:expenseAmount]];
    total += expenseAmount;
    [db executeUpdate:totalQuery, [[NSNumber alloc] initWithFloat:total]];
    /**
     * NEED TO GET THE CALLING CONTROLLER SO WE CAN TELL IT WHATS UP.
     */
    [parentController updateFromChild];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        /* The Deposit cell was hit */
        if (self->isDeposit) {
            self->isDeposit = NO;
            deposit.accessoryType = UITableViewCellAccessoryNone;
        } else {
            self->isDeposit = YES;
            deposit.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)viewDidUnload {
    [self setDescription:nil];
    [self setAmount:nil];
    [self setDeposit:nil];
    [super viewDidUnload];
}
@end
