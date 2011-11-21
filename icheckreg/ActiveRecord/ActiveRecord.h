//
//  Created by dean on 11/9/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "FMDatabase.h"

#define DB_DATE_FORMAT @"yyyy-MM-dd HH:mm:ss"

@interface ActiveRecord : NSObject {

}

@property NSUInteger primaryKey;

+ (void)setDatabase:(FMDatabase *)db;
+ (NSUInteger)count;
+ (NSUInteger)count:(NSString *)where, ...;
+ (NSArray *)findWhere:(NSString *)where, ...;
+ (NSArray *)findWithSql:(NSString *)sql, ...;
+ (id)findById:(NSUInteger)primaryKey;

- (void)save;
- (void)delete;

@end
