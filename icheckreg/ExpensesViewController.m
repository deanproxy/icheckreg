//
//  ExpensesViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExpensesViewController.h"
#import "icheckregAppDelegate.h"
#import "AddExpenseViewController.h"
#import "Expense.h"
#import "Total.h"

@implementation ExpensesViewController

@synthesize listData = _listData;
@synthesize tableView = _tableView;

const uint MAX_PAGE_ROWS = 50;


- (void)getExpenses {
    NSMutableArray *currentList = nil;
    NSString *prevDate = nil;
    
    NSString *query = [[NSString alloc] initWithFormat:@"select primaryKey,synced,note,total,createdAt from Expense order by createdAt desc limit %d,%d", offset, MAX_PAGE_ROWS];
    NSLog(@"%@", query);
    
    /* If list is already populated, get the last object */
    if ([self.listData count] > 0) {
        currentList = [self.listData lastObject];
    }
	
	NSArray *expenses = [Expense findWithSql:query];
	for (Expense *expense in expenses) {
		NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
        NSString *thisDate = [format stringFromDate:expense.createdAt];
        /* If list has been populated before, try to get the last date */
        if (prevDate == nil && currentList != nil) {
            Expense *last = [currentList objectAtIndex:0];
            prevDate = [format stringFromDate:last.createdAt];
        }
        
        /* if the current date doesn't match the previous date, we're creating a new section */
        if (prevDate == nil || [prevDate compare:thisDate] != NSOrderedSame) {
            prevDate = [format stringFromDate:expense.createdAt];
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
    Total *totalObj = [Total findById:0];

	[expense delete];
	float total = [totalObj.total floatValue];
	total -= [expense.total floatValue];
	totalObj.total = [NSNumber numberWithFloat:total];
    [totalObj save];
	self->totalRows -= 1;

	/* remove the entire object if it's the last row in the section */
	if ([[self.listData objectAtIndex:indexPath.section] count] <= 1) {
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:indexPath.section];
		[self.listData removeObjectAtIndex:indexPath.section];
		[tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationLeft];
	} else {
    	[[self.listData objectAtIndex:indexPath.section] removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}

    [tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    offset = 0;
    _listData = [[NSMutableArray alloc] init];
    
    [self getExpenses];
    
	self->totalRows = [Expense count];
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
    return [formatter stringFromDate:expense.createdAt];
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
        [theTitle setText:expense.note];
        [theTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16.0]];
        [cell.contentView addSubview:theTitle];
        
        cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"$%.02f", [expense.total floatValue]];

        if ([expense.total floatValue] > -1) {
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


- (IBAction)addExpense {
	AddExpenseViewController *add = [[AddExpenseViewController alloc] init];
	add.delegate = self;
	[self.navigationController presentModalViewController:add animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"ExpenseAddExpense"]) {
		UINavigationController *nav = segue.destinationViewController;
		AddExpenseViewController *add = [[nav viewControllers] objectAtIndex:0];
		add.delegate = self;
	}
}

- (void)didSave:(AddExpenseViewController *)controller {
	/* Reload list */
	offset = 0;
	self.listData = nil;
	self.listData = [[NSMutableArray alloc] init];
	[self getExpenses];
	[self.tableView reloadData];
}

@end


