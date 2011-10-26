//
//  ExpensesViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExpensesViewController.h"
#import "icheckregAppDelegate.h"

@implementation ExpensesViewController

@synthesize listData = _listData;

- (void)viewDidLoad {
    [super viewDidLoad];
    _listData = [[NSMutableArray alloc] init];
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURL *dbPath = [delegate dbFilePath];
    const char *charDbPath = [[dbPath absoluteString] UTF8String];
    if (sqlite3_open(charDbPath, &self->database) != SQLITE_OK) {
        sqlite3_close(self->database);
        NSAssert(0, @"Failed to open database");
    }
    NSString *query = @"select id,synced,note,total,created_at from expense limit 30";
    sqlite3_stmt *statement = NULL;
    if (sqlite3_prepare_v2(self->database, [query UTF8String], -1, &statement, NULL) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW) {
            Expense *expense = [[Expense alloc] init];
            expense->expenseId = sqlite3_column_int(statement, 0);
            expense->synced = sqlite3_column_int(statement, 1);
            
            char *note = (char *)sqlite3_column_text(statement, 2);
            float total = sqlite3_column_double(statement, 3);
            char *created_at = (char *)sqlite3_column_text(statement, 4);
            
            expense->note = [[NSString alloc] initWithUTF8String:note];
            expense->total = [[NSNumber alloc] initWithFloat:total];
            
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"yyyy-mm-dd"];
            NSDate *date = [dateFormat dateFromString:[[NSString alloc] initWithUTF8String:created_at]];
            [dateFormat setDateFormat:@"MMM d, yyyy"];
            expense->created_at = [dateFormat stringFromDate:date];
            
            [self.listData addObject:expense];
        }
        sqlite3_finalize(statement);
    }
}

- (void)viewDidUnload {
    self.listData = nil;
    sqlite3_close(self->database);
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /* Should be the total number of different dates in the list */
    int count = 0;
    NSString *query = @"select count(1) from (select count(1) from expense group by created_at)";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(self->database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        if (sqlite3_step(statement) == SQLITE_ROW) {
            count = sqlite3_column_int(statement, 0);
        } else {
            NSLog(@"Couldn't get a count of rows");
        }
        sqlite3_finalize(statement);
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /* This should be the number of rows available for a specific day */
    int count = 0;
    int index = 0;
    NSString *query = @"select count(1) from expense group by created_at";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(self->database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW && index < section) {
            count = sqlite3_column_int(statement, 0);
        } 
        sqlite3_finalize(statement);
    }
    return [self.listData count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /* This should be the date for each section (Oct 22nd, 2011) */
    Expense *expense = [self.listData objectAtIndex:section];
    return (expense->created_at);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableIdentifier = @"TableIdentifier";
    
    /* Ask for a pre-used cell (one that may be off the screen) */
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
    /* If we didn't get back a cell, create a new one */
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableIdentifier];
    }
    NSUInteger row = [indexPath row];
    Expense *expense = [self.listData objectAtIndex:row];
    cell.textLabel.text = expense->note;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"$%.02f", [expense->total floatValue]];

    /* For some reason the background colors are black... Need to set to white. */
    [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor whiteColor]];
    if ([expense->total floatValue] > -1) {
        /* BUG: When scrolling off screen and then back on again, it appears as if some values that
           are not greater than -1 are still getting a green color */
        /* If the item is a deposit, make it stand out. */
        cell.detailTextLabel.textColor = [UIColor greenColor];
    }
    
    return cell;
}

@end

@implementation Expense


@end

