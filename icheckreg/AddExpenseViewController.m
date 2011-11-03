//
//  AddExpenseViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddExpenseViewController.h"
#import "icheckregAppDelegate.h"

@implementation AddExpenseViewController

@synthesize delegate;
@synthesize description;
@synthesize amount;
@synthesize deposit;

- (void)viewDidLoad {
    if (self->expenseId > 0) {
        
    }
}


/* Strip all characters except for numbers and decimal point */
- (NSString *)onlyDigits:(NSString *)inputString {
	NSMutableString *strippedString = [NSMutableString stringWithCapacity:inputString.length];

	NSScanner *scanner = [NSScanner scannerWithString:inputString];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];

	while ([scanner isAtEnd] == NO) {
		NSString *buffer;
		if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
			[strippedString appendString:buffer];

		} else {
			[scanner setScanLocation:([scanner scanLocation] + 1)];
		}
	}
	return strippedString;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	textField.text = [self onlyDigits:textField.text];
	return [textField.text length] > 0;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    float total = 0.0;
    icheckregAppDelegate *app = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = app.db;
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
    if (self->expenseId) {
        query = @"update expense set note=?, total=?";
    }
    [db executeUpdate:query, self.description.text, [[NSNumber alloc] initWithFloat:expenseAmount]];
    total += expenseAmount;
    [db executeUpdate:totalQuery, [[NSNumber alloc] initWithFloat:total]];

    NSNotificationCenter *notifier = [NSNotificationCenter defaultCenter];
    [notifier postNotificationName:@"AddExpense" object:nil];
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
