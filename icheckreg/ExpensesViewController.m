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

const uint MAX_PAGE_ROWS = 50;

- (void)getExpenses {
    NSMutableArray *currentList = nil;
    NSString *prevDate = nil;
    
    NSString *query = [[NSString alloc] initWithFormat:@"select id,synced,note,total,created_at from expense order by created_at desc limit %d,%d", offset, MAX_PAGE_ROWS];
    FMResultSet *resultSet = [db executeQuery:query];
    while ([resultSet next]) {
        Expense *expense = [[Expense alloc] init];
        expense->expenseId = [resultSet intForColumn:@"id"];
        expense->synced = [resultSet boolForColumn:@"synced"];
        
        expense->note = [resultSet stringForColumn:@"note"];
        expense->total = [[NSNumber alloc] initWithFloat:[resultSet doubleForColumn:@"total"]];
        NSString *dateString = [resultSet stringForColumn:@"created_at"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        expense->created_at = [format dateFromString:dateString];
        
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *thisDate = [format stringFromDate:expense->created_at];
        /* If listData has been populated before, try to get the last date */
        if (prevDate == nil && [self.listData count] > 0) {
            prevDate = [format stringFromDate:[[self.listData lastObject] objectAtIndex:0]];
        }
        if (prevDate == nil || [prevDate compare:thisDate] != NSOrderedSame) {
            prevDate = [format stringFromDate:expense->created_at];
            currentList = [[NSMutableArray alloc] init];
            [self.listData addObject:currentList];
        }
        [currentList addObject:expense];
    }
    offset += MAX_PAGE_ROWS;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    offset = 0;
    _listData = [[NSMutableArray alloc] init];
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSURL *dbPath = [delegate dbFilePath];
    
    self->db = [FMDatabase databaseWithPath:[dbPath absoluteString]];
    if (![self->db open]) {
        NSAssert(0, @"Failed to open database");
    }
    [self getExpenses];
    
    /* Get total rows available */
    NSString *query = @"select count(1) from expense";
    FMResultSet *resultSet = [db executeQuery:query];
    if ([resultSet next]) {
        self->totalRows = [resultSet intForColumnIndex:0];
    }
}

- (void)viewDidUnload {
    self.listData = nil;
    [self->db close];
    [super viewDidUnload];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    /* Should be the total number of different dates in the list */
    return [self.listData count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    /* This should be the number of rows available for a specific day */
    int count = [[self.listData objectAtIndex:section] count];
    int listDataCount = [self.listData count];
    if ((section+1) == listDataCount) {
        /* If we're the last row, check to see if we need to add 1 to count for the "Load More" section */
        uint totalListed = 0;
        for (uint i=0; i < listDataCount; i++) {
            totalListed += [[self.listData objectAtIndex:i] count];
        }
        if (self->totalRows > totalListed) {
            count += 1;
        }
    }
    return count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger sec = [indexPath section];
    NSUInteger row = [indexPath row];
    
    /** THE TABLE CELL WILL NOT DESELECT!!! */
    if (sec+1 == [self.listData count] && row >= [[self.listData objectAtIndex:sec] count]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [self->loadMoreIndicator startAnimating];
        sleep(4);
        [self getExpenses];
        [tableView reloadData];
        [self->loadMoreIndicator stopAnimating];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /* This should be the date for each section (Oct 22nd, 2011) */
    Expense *expense = [[self.listData objectAtIndex:section] objectAtIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
    NSLog(@"Header date: %@", [expense->created_at description]);
    return [formatter stringFromDate:expense->created_at];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *TableIdentifier = @"TableIdentifier";
    NSUInteger sec = [indexPath section];
    NSUInteger row = [indexPath row];
    UITableViewCell *cell = nil;
    
    
    if (sec+1 == [self.listData count] && row >= [[self.listData objectAtIndex:sec] count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMore"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"LoadMore"];            
        }
        cell.textLabel.text = @"Load more...";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.textLabel.textColor = [[UIColor alloc] initWithRed:0.219 green:0.330 blue:0.529 alpha:1.0];
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"%d total expenses", self->totalRows];
        
        loadMoreIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell setAccessoryView:loadMoreIndicator];
    } else {
        /* Ask for a pre-used cell (one that may be off the screen) */
        cell = [tableView dequeueReusableCellWithIdentifier:TableIdentifier];
        /* If we didn't get back a cell, create a new one */
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:TableIdentifier];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        Expense *expense = [[self.listData objectAtIndex:sec] objectAtIndex:row];
        
        /* We want to enforce the size of the main label, this is a hacky way to do it */
        UILabel *theTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 25)];                        
        [theTitle setText:expense->note];
        [theTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
        [cell.contentView addSubview:theTitle];
        
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"$%.02f", [expense->total floatValue]];

        if ([expense->total floatValue] > -1) {
            /* If the item is a deposit, make it stand out. */
            cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:0.0 green:153.0/255.0 blue:0.0 alpha:1.0];
        } else {
            /* This RGB value should be the default detail text color */
            cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:0.219 green:0.330 blue:0.529 alpha:1.0];
        }
    }

    /* For some reason the background colors are black... Need to set to white. */
    [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor whiteColor]];
    

    return cell;
}

@end

@implementation Expense


@end

