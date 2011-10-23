//
//  AddExpenseViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AddExpenseViewController.h"

@implementation AddExpenseViewController

@synthesize delegate;
@synthesize description;
@synthesize amount;
@synthesize deposit;

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender {
    NSString *message = [[NSString alloc] initWithFormat:@"%@ => %@", self.description.text, self.amount.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Results" 
                                                    message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
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
