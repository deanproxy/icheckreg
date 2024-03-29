//
//  icheckregAppDelegate.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "icheckregAppDelegate.h"
#import "Expense.h"
#import "Total.h"
#import "FMDatabase.h"

@implementation icheckregAppDelegate

@synthesize window = _window;
@synthesize db = _db;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	/* Set up ActiveRecord */
    NSURL *dbPath = [self dbFilePath];
	self.db = [FMDatabase databaseWithPath:[dbPath absoluteString]];
	[self.db open];
	self.db.traceExecution = YES;
	[ActiveRecord setDatabase:self.db];

    NSString *query = @"create table if not exists Expense (primaryKey integer primary key autoincrement, synced boolean not null default false, note varchar(50) not null, total float not null, createdAt timestamp default current_timestamp)";
    [self.db executeUpdate:query];

    query = @"create table if not exists Total (primaryKey integer primary key autoincrement, total float not null)";
    [self.db executeUpdate:query];

    return YES;
}

- (void)dealloc {
	[self.db close];
    self.db = nil;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}



/* TODO *************************** TODO
	- Break this up into smaller functions.
	- Make this function callable from any place that this is its delegate.
*/
- (void)backgroundTaskToSyncData {
	NSString *query = @"select id,note,total,createdAt from expenses where synced='false'";
	NSArray *expenses = nil; // [Expense findByColumn:@"synced" value:@"false"];
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSMutableString *ids = [[NSMutableString alloc] init];

	for (Expense *expense in expenses) {
		NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:expense.note, @"note", expense.total,
						@"total", expense.createdAt, @"createdAt", nil];
		[array addObject:[dict copy]];
		[ids appendFormat:@"%d,", expense.primaryKey];
	}

	NSError *error = nil;
	NSData *json = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
	NSUInteger length = [ids length];
	if (length > 0) {
		/* Remove the trailing comma */
		NSRange range = NSMakeRange(length-1, 1);
		[ids deleteCharactersInRange:range];
	}

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://budget.deanproxy.com/sync/"]];
	[request setHTTPMethod:@"POST"];
	[request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[request setHTTPBody:json];
	NSURLResponse *response = nil;
	NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	float total = 0.0;
	if (responseData) {
		id jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&error];
		/* Should be an array */
		Total *totalObj = [Total findById:0];
		total = [totalObj.total floatValue];
		if ([jsonObject respondsToSelector:@selector(objectAtIndex:)]) {
			for (int i=0; i < [jsonObject length]; i++) {
				NSDictionary *dict = [jsonObject objectAtIndex:i];
				Expense *expense = [[Expense alloc] init];
				expense.total = [dict objectForKey:@"total"];
				expense.note = [dict objectForKey:@"note"];
				expense.synced = YES;
				[expense setCreatedAtByString:[dict objectForKey:@"created_at"]];
				[expense save];
				total += [expense.total floatValue];
			}
		}
		totalObj.total = [[NSNumber alloc] initWithFloat:total];
		[totalObj save];
	}
}

- (void)syncData {
	[NSThread detachNewThreadSelector:@selector(backgroundTaskToSyncData) toTarget:self withObject:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
//	[self syncData];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)dbFilePath {
    return [self.applicationDocumentsDirectory URLByAppendingPathComponent:DB_FILE];
}



@end
