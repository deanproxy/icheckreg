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
#import "Total.h"
#import "Expense.h"

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
    BOOL valid = YES;
	if (textField == self.description) {
        valid = YES;
    } else if (textField == self.amount) {
        textField.text = [self onlyDigits:textField.text];
    }
	return valid;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    float total = 0.0;
    if ([self.description.text isEqualToString:@""] || [self.amount.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait a second..." message:@"You must enter a description and an amount to save." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return;
    }

    float expenseAmount = amount.text.floatValue;
    if (!self->isDeposit) {
        expenseAmount = -expenseAmount;
    }
	Expense *expense = [[Expense alloc] init];
	expense.note = self.description.text;
	expense.total = [NSNumber numberWithFloat:expenseAmount];
	expense.createdAt = [NSNull null];
	[expense save];

    total += expenseAmount;
	Total *totalObj = [Total findById:1];
    if (!totalObj) {
        /* in case table hasn't be created yet */
        totalObj = [[Total alloc] init];
    }
	totalObj.total = [NSNumber numberWithFloat:total];
	[totalObj save];

	[self.delegate didSave:nil];
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
