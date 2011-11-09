//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "Expense.h"

@implementation Expense

@synthesize total = _total;
@synthesize note = _note;
@synthesize created_at = _created_at;
@synthesize synced = _synced;

- (void)setCreatedAtByString:(NSString *)date {
	[self setCreatedAtByString:date withFormat:DB_DATE_FORMAT];
}

- (void)setCreatedAtByString:(NSString *)date withFormat:(NSString *)format {
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:format];
	self.createdAt = [formatter dateFromString:date];
}

@end