//
//  Created by dean on 11/9/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface ActiveRecord : NSObject {

}

@property NSUInteger primaryKey;

+ (void)setDatabase:(FMDatabase *)db;
+ (NSArray *)findWhere:(NSString *)where, ...;
+ (NSArray *)findWithSql:(NSString *)sql, ...;
+ (id)findById:(NSUInteger)primaryKey;

- (void)save;
- (void)delete;

@end