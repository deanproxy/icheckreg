//
//  Expense.h
//  icheckreg
//
//  Created by Dean Jones on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Expense : NSManagedObject

@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * note;
@property (nonatomic, retain) NSNumber * synced;
@property (nonatomic, retain) NSNumber * total;

@end
