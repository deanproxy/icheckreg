//
//  ExpensesViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExpensesViewController.h"
#import "Expense.h"
#import "icheckregAppDelegate.h"

@implementation ExpensesViewController

@synthesize listData = _listData;
@synthesize context = _context;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    self.context = [delegate managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription 
                                   entityForName:@"Expense" inManagedObjectContext:self.context];
    [fetch setEntity:entity];
    NSError *error;
    self.listData = [self.context executeFetchRequest:fetch error:&error]; 
    if (self.listData == nil) {
        NSLog(@"Failed to get data: %@ [%@]", error, [error userInfo]);
    }
}

- (void)viewDidUnload {
    self.listData = nil;
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /* Should be the total number of different dates in the list */
    return [self.listData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /* This should be the number of rows available for a specific day */
    return [self.listData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /* This should be the date for each section (Oct 22nd, 2011) */
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MMM d, yyyy"];
    Expense *expense = [self.listData objectAtIndex:section];
    return [dateFormat stringFromDate:expense.created_at] ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableIdentifier = @"TableIdentifier";
    
    /* Ask for a pre-used cell (one that may be off the screen) */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    /* If we didn't get back a cell, create a new one */
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableIdentifier];
    }
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    Expense *expense = [self.listData objectAtIndex:row];
    cell.textLabel.text = expense.note;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"$%.02f", [expense.total floatValue]];

    /* For some reason the background colors are black... Need to set to white. */
    [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor whiteColor]];
    if ([expense.total floatValue] > -1) {
        /* If the item is a deposit, make it stand out. */
        cell.detailTextLabel.textColor = [UIColor greenColor];
    }
    
    return cell;
}

@end

