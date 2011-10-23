//
//  ExpensesViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ExpensesViewController.h"

@implementation ExpensesViewController

@synthesize listData;

- (void)viewDidLoad {
    self.listData = [[NSArray alloc] initWithObjects: 
                     [[NSArray alloc] initWithObjects:
                        [[Expense alloc] initWithString: @"Fuck" date:@"October 12, 2011" total:-100.0001], 
                        [[Expense alloc] initWithString: @"Tuple" date:@"October 12, 2011" total:-50.010012],
                        [[Expense alloc] initWithString: @"Dean is Great" date:@"October 12, 2011" total:200.0332],
                        nil
                     ],
                     [[NSArray alloc] initWithObjects:
                        [[Expense alloc] initWithString: @"Stuff" date:@"December 12, 2010" total:-12.1111],
                        [[Expense alloc] initWithString: @"Posters" date:@"December 12, 2010" total:-42.011],
                        [[Expense alloc] initWithString: @"Monitor" date:@"December 12, 2010" total:-53.3433],
                        nil 
                     ],
                     nil
                    ];
    [super viewDidLoad];
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
    return [[self.listData objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    /* This should be the date for each section (Oct 22nd, 2011) */
    Expense *expense = [[self.listData objectAtIndex:section] objectAtIndex:0];
    return expense.date;
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
    Expense *expense = [[listData objectAtIndex:section] objectAtIndex:row];
    cell.textLabel.text = expense.note;
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"$%.02f", expense.total];

    /* For some reason the background colors are black... Need to set to white. */
    [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
    [cell.detailTextLabel setBackgroundColor:[UIColor whiteColor]];
    if (expense.total > -1) {
        /* If the item is a deposit, make it stand out. */
        cell.detailTextLabel.textColor = [UIColor greenColor];
    }
    
    return cell;
}

@end

@implementation Expense

@synthesize note=_note;
@synthesize date=_date;
@synthesize total=_total;
                                                    
- (id)initWithString: (NSString *)newNote date:(NSString *)newDate total:(float)newTotal {
    if (self = [super init]) {
        self.note = newNote;
        self.date = newDate;
        self.total = newTotal;
    }
    return self;
}

@end
