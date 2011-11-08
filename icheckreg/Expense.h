//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define DB_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"

@interface Expense : NSObject

@property (nonatomic, retain) NSNumber *expenseId;
@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSNumber *total;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic) Boolean synced;

@property (nonatomic, retain) FMDatabase *db;

+ (Expense *)expenseWithId:(NSNumber *)expenseId andDbConnection:(FMDatabase *)db;
- (id)initWithDb:(FMDatabase *)db;
- (id)initWithDict:(NSDictionary *)dict andDbConnection:(FMDatabase *)db;
- (void)save;
- (void)setCreatedAtByString:(NSString *)date;
- (void)setCreatedAtByString:(NSString *)date withFormat:(NSString *)format;


@end