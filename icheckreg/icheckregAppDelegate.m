//
//  icheckregAppDelegate.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "icheckregAppDelegate.h"

@implementation icheckregAppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    sqlite3 *database = nil;
    NSURL *dbPath = [self dbFilePath];
    if (sqlite3_open([[dbPath absoluteString] UTF8String], &database) != SQLITE_OK) {
        NSAssert(0, @"Failed to open database.");
    }
    NSString *query = @"create table if not exists expense (id integer primary key autoincrement, synced boolean not null default false, note varchar(50) not null, total float not null, created_at datetime not null default current_timestamp)";
    char *errorMsg = NULL;
    if (sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        NSAssert1(0, @"Error creating table: %s", errorMsg);
    }
    query = @"insert into expense (note, total) values('Hello, Dean', -3.14159)";
    sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg);
    query = @"insert into expense (note, total) values('Big expense', -300.14159)";
    sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg);
    query = @"insert into expense (note, total) values('Money, money, money!', 500.14159)";
    sqlite3_exec(database, [query UTF8String], NULL, NULL, &errorMsg);
    
    sqlite3_close(database);
    return YES;
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
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
