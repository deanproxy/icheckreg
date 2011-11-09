//
//  icheckregAppDelegate.h
//  icheckreg
//
//  Created by Dean Jones on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CheckregDatabase.h

@interface icheckregAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, assign) CheckregDatabase *db;

- (NSURL *)applicationDocumentsDirectory;
- (NSURL *)dbFilePath;

@end
