//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ActiveRecord.h"

@interface Expense : ActiveRecord

@property (nonatomic, retain) NSString *note;
@property (nonatomic, retain) NSNumber *total;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic) Boolean synced;

- (void)setCreatedAtByString:(NSString *)date;
- (void)setCreatedAtByString:(NSString *)date withFormat:(NSString *)format;

@end