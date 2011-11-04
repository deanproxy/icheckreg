//
//  icheckregAppDelegate.m
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "icheckregAppDelegate.h"
#import "FMDatabase.h"

@implementation icheckregAppDelegate

@synthesize window = _window;
@synthesize db = _db;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *dbPath = [self dbFilePath];
    self.db = [[FMDatabase alloc] initWithPath:[dbPath absoluteString]];
    NSAssert(self.db != nil, @"Couldn't get to database %@", [dbPath absoluteString]);
    [self.db open];
    NSString *query = @"create table if not exists expenses (id integer primary key autoincrement, synced boolean not null default false, note varchar(50) not null, total float not null, created_at datetime not null default current_timestamp)";
    [self.db executeUpdate:query];

    query = @"create table if not exists total (id integer primary key autoincrement, total float not null)";
    [self.db executeUpdate:query];

    return YES;
}

- (void)dealloc {
    [self.db close];
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
