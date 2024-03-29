//
//  icheckregMasterViewController.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "icheckregMasterViewController.h"
#import "ExpensesViewController.h"
#import "AddExpenseViewController.h"
#import "Total.h"

@implementation icheckregMasterViewController

@synthesize context = _context;

- (NSNumber *)getTotal {
    Total *total = [Total findById:1];
	if (!total) {
		total = [[Total alloc] init];
		total.total = [NSNumber numberWithFloat:0.0];
	}
    return total.total;
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)updateTotal:(UITableViewCell *)cell {
    /* Update the total */
    NSNumber *total = [self getTotal];
    cell.detailTextLabel.text = [[NSString alloc] initWithFormat:@"$%.02f", [total floatValue]];
    if ([total floatValue] > -1) {
        /* If the item is a deposit, make it stand out. */
        cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:0.0 green:153.0/255.0 blue:0.0 alpha:1.0];
    } else {
        /* This RGB value should be the default detail text color */
        cell.detailTextLabel.textColor = [[UIColor alloc] initWithRed:255.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (row == 0) {
        [self updateTotal:cell];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    if (row == 0) {
        /* Update the total */
        [self updateTotal:[tableView cellForRowAtIndexPath:indexPath]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (row == 1) {
        ExpensesViewController *expenseView = [[ExpensesViewController alloc] init];
        [self.navigationController pushViewController:expenseView animated:YES];
    }
}


/**
 * HOWTO HOOK UP A BUTTON TO AN ACTION -
 * 
 * - Create a method that returns IBAction such as the one below.
 * - Go into storyboard and CTRL+CLICK+DRAG down to the Controller icon (The one on the right in the icon bar below the view)
 * - Select the name of the method you just created.
 */
- (IBAction)settings:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Settings Disabled" message:@"There are no settings yet." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.identifier isEqualToString:@"MainAddExpense"]) {
		UINavigationController *nav = segue.destinationViewController;
		AddExpenseViewController *add = [[nav viewControllers] objectAtIndex:0];
		add.delegate = self;
	}
}

- (void)didSave: (AddExpenseViewController *)controller {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
	[self updateTotal:cell];
}

@end
