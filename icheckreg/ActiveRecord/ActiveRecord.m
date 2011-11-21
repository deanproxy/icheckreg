//
//  Created by dean on 11/9/11.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <objc/runtime.h>
#import "ActiveRecord.h"

static FMDatabase *database = nil;

@interface PropertyInfo : NSObject {

}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) id value;

@end

@implementation PropertyInfo

@synthesize name = _name;
@synthesize type = _type;

@end

@implementation ActiveRecord

@synthesize primaryKey = _primaryKey;

+ (void)assertDatabaseValid {
	NSAssert(database != nil, @"ActiveRecord: Database not set.");
}

+ (void)setDatabase:(FMDatabase *)db {
	database = db;
}

/* TODO: FIXME: Can we make this more robust? Look at the attribute string more closely and parse better. */
+ (NSString *)propertyTypeFromString:(NSString *)attributeString {
    // Format should be T@"Type",&,Vstuff
    NSString *type = @"Native";
    NSArray *components = [attributeString componentsSeparatedByString:@"\""];
    if ([components count] >= 2) {
        NSString *afterQuote = [components objectAtIndex:1];
        components = [afterQuote componentsSeparatedByString:@"\""];
        type = [components objectAtIndex:0];
    }
    return type;
}

+ (NSArray *)getPropertyInfo {
	NSMutableArray *propertyNames = [NSMutableArray array];
	u_int propertyCount = 0;
	objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    id klass = [[self alloc] init];

	for (int i=0; i < propertyCount; i++) {
        PropertyInfo *propertyInfo = [[PropertyInfo alloc] init];
		objc_property_t property = properties[i];
		const char *name = property_getName(property);
        propertyInfo.name = [NSString stringWithUTF8String:name];
        NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
        propertyInfo.type = [self propertyTypeFromString:attributes];
		[propertyNames addObject:propertyInfo];
	}
	return propertyNames;
}

+ (NSArray *)resultsToArrayOfClass:(FMResultSet *)results {
	NSMutableArray *objects = [NSMutableArray array];
	NSArray *properties = [self getPropertyInfo];

	while ([results next]) {
		id row = [[self alloc] init];

		for (PropertyInfo *property in properties) {
			id value = [results objectForColumnName:property.name];
            /* Dates come back as strings, so make sure we transform them into NSDate */
            if ([property.type compare:@"NSDate"] == 0) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:DB_DATE_FORMAT];
                [row setValue:[formatter dateFromString:value] forKey:property.name];
            } else {
                [row setValue:value forKey:property.name];
            }
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
    
    NSMutableString *query = [[NSMutableString alloc] init];
    NSArray *properties = [[self class] getPropertyInfo];
    NSMutableArray *values = [NSMutableArray array];
    NSUInteger propertyCount = [properties count];

    /* TODO: Update doesn't work right now because we aren't getting our primarykey back in the properties! */
    if (self.primaryKey > 0) {
        /* Update */
        [query appendFormat:@"update %@ set ", [self class]];
        for (int i=0; i < propertyCount; i++) {
            PropertyInfo *property = [properties objectAtIndex:i];
            id value = [self valueForKey:property.name];
            if (![value isKindOfClass:[NSNull class]]) {
                [query appendFormat:@"%@ = ?", property.name];
                [values addObject:value];
                if (i+1 < propertyCount) {
                    [query appendString:@", "];
                }
            }
        }
    } else {
        /* Insert */
        [query appendFormat:@"insert into %@ (", [self class]];
        for (int i=0; i < propertyCount; i++) {
            PropertyInfo *property = [properties objectAtIndex:i];
            id value = [self valueForKey:property.name];
            if (![value isKindOfClass:[NSNull class]]) {
                [query appendFormat:@"%@", property.name];
                [values addObject:value];
                if (i+1 < propertyCount) {
                    [query appendString:@","];
                }
            }
        }
        [query appendFormat:@") values("];
        NSUInteger valueCount = [values count];
        for (int i=0; i < valueCount; i++) {
            [query appendFormat:@"?"];
            if (i+1 < valueCount) {
                [query appendString:@", "];
            }
        }
        [query appendString:@")"];
    }
    
    [database executeUpdate:query withArgumentsInArray:values];
}

- (void)delete {
	[ActiveRecord assertDatabaseValid];
}

@end