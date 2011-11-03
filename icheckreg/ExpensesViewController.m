//
//  ExpensesViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExpensesViewController.h"
#import "icheckregAppDelegate.h"
#import "Expense.h"

@implementation ExpensesViewController

@synthesize listData = _listData;
@synthesize tableView = _tableView;

const uint MAX_PAGE_ROWS = 50;


- (void)getExpenses {
    NSMutableArray *currentList = nil;
    NSString *prevDate = nil;
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    FMDatabase *db = delegate.db;
    
    NSString *query = [[NSString alloc] initWithFormat:@"select id,synced,note,total,created_at from expenses order by created_at desc limit %d,%d", offset, MAX_PAGE_ROWS];
    NSLog(@"%@", query);
    FMResultSet *resultSet = [db executeQuery:query];
    
    /* If list is already populated, get the last object */
    if ([self.listData count] > 0) {
        currentList = [self.listData lastObject];
    }
    while ([resultSet next]) {
        Expense *expense = [[Expense alloc] init];
        expense->expenseId = [[NSNumber alloc] initWithInt:[resultSet intForColumn:@"id"]];
        expense->synced = [resultSet boolForColumn:@"synced"];
        
        expense->note = [resultSet stringForColumn:@"note"];
        expense->total = [[NSNumber alloc] initWithFloat:[resultSet doubleForColumn:@"total"]];
        NSString *dateString = [resultSet stringForColumn:@"created_at"];
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        expense->created_at = [format dateFromString:dateString];
        
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *thisDate = [format stringFromDate:expense->created_at];
        /* If list has been populated before, try to get the last date */
        if (prevDate == nil && currentList != nil) {
            Expense *last = [currentList objectAtIndex:0];
            prevDate = [format stringFromDate:last->created_at];
        }
        
        /* if the current date doesn't match the previous date, we're creating a new section */
        if (prevDate == nil || [prevDate compare:thisDate] != NSOrderedSame) {
            prevDate = [format stringFromDate:expense->created_at];
            currentList = [[NSMutableArray alloc] init];
            [self.listData addObject:currentList];
        }
        [currentList addObject:expense];
    }
    offset += MAX_PAGE_ROWS;
}


- (void)autoLoadExpenses:(UITableView *)tableView {
    [self getExpenses];
    [self.tableView  reloadData];
}

- (void)removeRow:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    Expense *expense = [[self.listData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *query = @"delete from expenses where id=?";
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    [delegate.db executeUpdate:query, expense->expenseId];
    query = @"select total from total";
    FMResultSet *result = [delegate.db executeQuery:query];
    if ([result next]) {
        float total = [result doubleForColumnIndex:0];
        total -= [expense->total floatValue];
        query = @"update total set total=? where id=1";
        [delegate.db executeUpdate:query, [[NSNumber alloc] initWithFloat:total]];
    }

	self->totalRows -= 1;

	/* remove the entire object if it's the last row in the section */
	if ([[self.listData objectAtIndex:indexPath.section] count] <= 1) {
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
		[self.listData removeObjectAtIndex:indexPath.section];
		[tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
	} else {
    	[[self.listData objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}

    [tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    offset = 0;
    _listData = [[NSMutableArray alloc] init];
    icheckregAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    [self getExpenses];
    
    /* Get total rows available */
    NSString *query = @"select count(1) from expenses";
    FMResultSet *resultSet = [delegate.db executeQuery:query];
    if ([resultSet next]) {
        self->totalRows = [resultSet intForColumnIndex:0];
    }
    
    NSNotificationCenter *notifier = [NSNotificationCenter defaultCenter];
    [notifier addObserver:self selector:@selector(updateFromChild) name:@"AddExpense" object:nil];
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
//    NSUInteger sec = [indexPath section];
//    NSUInteger row = [indexPath row];
//
//    /* TODO: How do I present this screen? */
//    Expense *expense = [[self.listData objectAtIndex:sec] objectAtIndex:row];
//    AddExpenseViewController *editExpense = [[AddExpenseViewController alloc] init];
//    editExpense.delegate = self;
//    editExpense.description.text = expense->note;
//    editExpense.amount.text = [expense->total stringValue];
//    editExpense->expenseId = expense->expenseId;
//    if ([expense->total floatValue] >= 0.0) {
//        editExpense.deposit.accessoryType = UITableViewCellAccessoryCheckmark;
//        editExpense->isDeposit = YES;
//    } else {
//        editExpense.deposit.accessoryType = UITableViewCellAccessoryNone;
//        editExpense->isDeposit = NO;
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    [self.navigationController presentModalViewController:editExpense animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /* This should be the date for each section (Oct 22nd, 2011) */
    Expense *expense = [[self.listData objectAtIndex:section] objectAtIndex:0];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM dd, yyyy"];
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
        
        UIActivityIndicatorView *loadMoreIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        loadMoreIndicator.center = CGPointMake(cell.contentView.bounds.size.width/2, cell.contentView.bounds.size.height/2);
        [cell addSubview:loadMoreIndicator];
        [loadMoreIndicator startAnimating];
        [NSThread detachNewThreadSelector:@selector(autoLoadExpenses:) toTarget:self withObject:tableView];
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

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self removeRow:tableView atIndexPath:indexPath];
    }
}

- (void)didSave:(AddExpenseViewController *)controller {
    
}

- (void)didCancel:(AddExpenseViewController *)controller {
    
}

- (void)updateFromChild {
    /* Reload the entire table */
    offset = 0;
    self.listData = nil;
    self.listData = [[NSMutableArray alloc] init];
    [self getExpenses];
    [self.tableView reloadData];
}

@end


