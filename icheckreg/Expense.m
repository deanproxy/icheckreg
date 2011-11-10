//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Expense.h"

@implementation Expense

@synthesize total = _total;
@synthesize note = _note;
@synthesize createdAt = _createdAt;
@synthesize synced = _synced;

/* TODO: Figure you how to translate createdAt back and forth to an NSDate from the DB (which will be an INTEGER) */
- (NSDate *)get_createdAt {
	return [NSDate dateWithTimeIntervalSince1970:[_createdAt longValue]];
}

- (void)setCreatedAtByString:(NSString *)date {
	[self setCreatedAtByString:date withFormat:DB_DATE_FORMAT];
}

- (void)setCreatedAtByString:(NSString *)date withFormat:(NSString *)format {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	self.created_at = [formatter dateFromString:date];
}

@end