//
//  icheckregAppDelegate.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"

@interface icheckregAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) FMDatabase *db;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)dbFilePath;

@end
