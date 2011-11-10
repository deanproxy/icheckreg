//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ActiveRecord.h"

#define DB_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"

@interface Expense : ActiveRecord

@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSNumber *total;
@property (nonatomic, retain) NSDate *created_at;
@property (nonatomic) Boolean synced;

- (void)setCreatedAtByString:(NSString *)date;
- (void)setCreatedAtByString:(NSString *)date withFormat:(NSString *)format;

@end