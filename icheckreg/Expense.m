//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Expense.h"

@implementation Expense

@synthesize expenseId = _expenseId;
@synthesize total = _total;
@synthesize note = _note;
@synthesize createdAt = _createdAt;
@synthesize synced = _synced;

@synthesize db = _db;

+ (Expense *)expenseWithId:(NSNumber *)expenseId andDbConnection:(FMDatabase *)db {
	Expense *expense = [[Expense alloc] initWithDb:db];
	FMResultSet *result = [db executeQuery:@"select id,total,note,created_at,synced from expenses where id=?", expenseId];
	if ([result next]) {
		expense.expenseId = [[NSNumber alloc] initWithInt:[result intForColumnIndex:0]];
		expense.total = [[NSNumber alloc] initWithDouble:[result doubleForColumnIndex:1]];
		expense.note = [result stringForColumnIndex:2];
		[expense setCreatedAtByString:[result stringForColumnIndex:3]];
		expense.synced = [result boolForColumnIndex:4];
	} else {
		NSLog(@"No expense record found for id: %d", [expenseId intValue]);
		[NSException raise:@"No expense found" format:@"Expense with id %d not found", [expenseId intValue]];
	}
	return expense;
}

/* Write to the database. Update if needed */
- (void)save {
	if (self.expenseId > 0) {
		NSString *query = @"update expenses set total=?, note=?, synced=? where id=?";
		[self.db executeUpdate:query, self.total, self.note, self.synced, self.expenseId];
	} else {
		NSMutableString *query = [[NSMutableString alloc] initWithString:@"insert into expenes set total=?, note=?, synced=?"];
		if (self.createdAt) {
			[query appendString:@", created_at=?"];
			[self.db executeUpdate:query, self.total, self.note, self.synced, self.createdAt];
		} else {
			[self.db executeUpdate:query, self.total, self.note, self.synced];
		}
	}
}

- (id)initWithDb:(FMDatabase *)db {
	self.db = db;
	self.expenseId = 0;
	return self;
}

- (id)initWithDict:(NSDictionary *)dict andDbConnection:(FMDatabase *)db {
	self.db = db;
	self.expenseId = [dict objectForKey:@"id"];
	self.total = [dict objectForKey:@"total"];
	self.note = [dict objectForKey:@"note"];
	NSString *synced = [dict objectForKey:@"synced"];
	self.synced = [synced boolValue];
	[self setCreatedAtByString:[dict objectForKey:@"created_at"]];
	return self;
}

- (void)setCreatedAtByString:(NSString *)date {
	[self setCreatedAtByString:date withFormat:DB_DATE_FORMAT];
}

- (void)setCreatedAtByString:(NSString *)date withFormat:(NSString *)format {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	self.createdAt = [formatter dateFromString:date];
}

@end