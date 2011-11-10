//
//  Created by dean on 11/9/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <objc/runtime.h>
#import "ActiveRecord.h"

static FMDatabase *database = nil;
static NSMutableArray *propertyNames = nil;

@implementation ActiveRecord

@synthesize primaryKey = _primaryKey;

+ (void)assertDatabaseValid {
	NSAssert(database != nil, @"ActiveRecord: Database not set.");
}

+ (void)setDatabase:(FMDatabase *)db {
	database = db;
}

+ (NSArray *)getPropertyNames {
	if (propertyNames) {
		return propertyNames;
	}
	propertyNames = [NSMutableArray array];
	u_int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);

	for (int i=0; i < propertyCount; i++) {
		objc_property_t property = properties[i];
		const char *name = property_getName(property);
		[propertyNames addObject:[NSString stringWithCString:name encoding:NSUTF8StringEncoding]];
	}
	return propertyNames;
}

+ (NSArray *)resultsToArrayOfClass:(FMResultSet *)results {
	NSMutableArray *objects = [NSMutableArray array];
	NSArray *properties = [self getPropertyNames];
	while ([results next]) {
		id klass = [self class];
		id row = [[klass alloc] init];

		for (NSString *name in properties) {
			id value = [results objectForColumnName:name];
			[row setValue:value forKey:name];						
		}
		[objects addObject:row];
	}
	return objects;
}

+ (NSArray *)findWithSql:(NSString *)sql, ... {
	[self assertDatabaseValid];

	va_list args;
	va_start(args, sql);
	FMResultSet *results = [database executeQuery:sql withArgumentsInArray:nil orVAList:args];
	va_end(args);
	return [self resultsToArrayOfClass:results];
}

/*
 * Get records with a where clause.
 * Example: [Whatever findWhere:@"something = ?", @"yourmom"]
 */
+ (NSArray *)findWhere:(NSString *)where, ... {
	va_list args;
	va_start(args, where);
	NSString *sql = [[NSString alloc] initWithFormat:@"select * from %@ where %@", [self class], where];
	FMResultSet *results = [database executeQuery:sql withArgumentsInArray:nil orVAList:args];
	va_end(args);
	return [self resultsToArrayOfClass:results];
}

/*
 * Get a single record by it's primary key id.
 */
+ (id)findById:(NSUInteger)primaryKey {
	NSString *query = [[NSString alloc] initWithFormat:@"select * from %@ where primaryKey=?", [self class]];
	NSArray *result = [self findWithSql:query, [NSNumber numberWithInt:primaryKey]];
	id row = nil;
	if ([result count] > 0) {
		row = [result objectAtIndex:0];
	}
	return row;
}

+ (NSUInteger)count:(NSString *)where, ... {
	NSUInteger count = 0;
	NSString *query = [[NSString alloc] initWithFormat:@"select count(1) from %@ where %@", [self class], where];
	va_list args;
	va_start(args, where);
	FMResultSet *result = [database executeQuery:query withArgumentsInArray:nil orVAList:args];
	va_end(args);
	if ([result next]) {
		count = [result intForColumnIndex:0];		
	}
	return count;
}

+ (NSUInteger)count {
	return [self count:@"1=1"];
}

- (void)save {
	[ActiveRecord assertDatabaseValid];
}

- (void)delete {
	[ActiveRecord assertDatabaseValid];
}

@end