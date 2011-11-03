//
//  Created by dean on 11/2/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>


@interface Expense : NSObject {
@public
    NSNumber *expenseId;
    NSString *note;
    NSNumber *total;
    NSDate *created_at;
    BOOL synced;
}


@end