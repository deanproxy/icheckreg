//
//  ISModel.m
//  GroceryList
//
//  Created by Dylan Bruzenak on 6/18/09.
//  Copyright 2009 Dylan Bruzenak. All rights reserved.
//

#import "ISModel.h"
#import "ISDatabase.h"

static ISDatabase *database = nil;
static NSMutableDictionary *tableCache = nil;

@interface ISModel(PrivateMethods)
- (void) insert;
- (void) update;
@end

@implementation ISModel
@synthesize primaryKey;
@synthesize savedInDatabase;

+ (void) setDatabase: (ISDatabase *) newDatabase
{
	database = newDatabase;
}

+ (ISDatabase *) database
{
	return database;
}

+ (NSString *) tableName
{
	return NSStringFromClass([self class]);
}

+ (void) assertDatabaseExists
{
	NSAssert1(database, @"Database not set.  Set the database using [ISModel setDatabase] before using ActiveRecord.", @"");
}

- (NSArray *) columns
{
	if(tableCache == nil)
	{
		tableCache = [NSMutableDictionary dictionary];
	}
	
	NSString *tableName = [[self class] tableName];
	NSArray *columns = [tableCache objectForKey:tableName];
	
	if(columns == nil)
	{
		columns = [database columnsForTableName: tableName];
		[tableCache setObject: columns forKey: tableName];
	}
	
	return columns;
}

- (NSArray *) columnsWithoutPrimaryKey
{
	NSMutableArray *columns = [NSMutableArray arrayWithArray: [self columns]];
	[columns removeObjectAtIndex:0];
	
	return columns;
}

- (NSArray *) propertyValues
{
	NSMutableArray *values = [NSMutableArray array];
	for(NSString *columnName in [self columnsWithoutPrimaryKey])
	{
		id value = [self valueForKey: columnName];
		
		if(value != nil)
		{
			[values addObject: value];
		}else{
			[values addObject:[NSNull null]];
		}
	}
	return values;
}

#pragma mark -
#pragma mark Insert/Update/Delete

- (void) beforeSave
{
	
}

- (void) save
{
	[[self class] assertDatabaseExists];
	
	[self beforeSave];
	
	if(!savedInDatabase)
	{
		[self insert];
	}else{
		[self update];
	}
}

- (void) insert
{
	NSMutableArray *parameterList = [NSMutableArray array];
	
	NSArray *columnsWithoutPrimaryKey = [self columnsWithoutPrimaryKey];
	
	for(int i = 0; i < [columnsWithoutPrimaryKey count]; i++)
	{
		[parameterList addObject: @"?"];
	}
	
	NSString *sql = [NSString stringWithFormat:@"insert into %@ (%@) values(%@)", [[self class] tableName], [columnsWithoutPrimaryKey componentsJoinedByString: @","], 
					 [parameterList componentsJoinedByString:@","]];
	
	[database executeSql: sql withParameters: [self propertyValues]];
	savedInDatabase = YES;
	primaryKey = [database lastInsertRowId];
}

- (void) update
{
	NSString *setValues = [[[self columnsWithoutPrimaryKey] componentsJoinedByString:@" = ?, "] stringByAppendingString:@" = ?"];
	NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where primaryKey = ?", [[self class] tableName], setValues];
	
	NSArray *parameters = [[self propertyValues] arrayByAddingObject: [NSNumber numberWithUnsignedInt:primaryKey]];
	
	[database executeSql: sql withParameters: parameters];
	savedInDatabase = YES;
}

- (void) beforeDelete
{
	
}

- (void) delete
{
	[[self class] assertDatabaseExists];
	if(!savedInDatabase)
	{
		return;
	}
	
	[self beforeDelete];
	
	NSString *sql = [NSString stringWithFormat:@"delete from %@ where primaryKey = ?", [[self class] tableName]];
	[database executeSqlWithParameters: sql, [NSNumber numberWithUnsignedInt:primaryKey], nil];
	savedInDatabase = NO;
	primaryKey = 0;
}

#pragma mark -
#pragma mark Find Model Objects

+ (NSArray *) findWithSql: (NSString *) sql withParameters: (NSArray *) parameters
{
	[self assertDatabaseExists];
	
	NSArray *results = [database executeSql:sql withParameters: parameters withClassForRow: [self class]];
	
	[results setValue:[NSNumber numberWithBool:YES] forKey:@"savedInDatabase"];
	
	return results;
}

+ (NSArray *) findWithSqlWithParameters: (NSString *) sql, ...
{
	va_list argumentList;
	va_start(argumentList, sql);
	NSMutableArray *arguments = [NSMutableArray array];
	id argument;
	
	while(argument = va_arg(argumentList, id))
	{
		[arguments addObject:argument];
	}
	
	va_end(argumentList);
	
	return [self findWithSql:sql withParameters: arguments];
}

+ (NSArray *) findWithSql: (NSString *) sql
{
	return [self findWithSqlWithParameters:sql, nil];
}

+ (NSArray *) findByColumn: (NSString *) column value: (id) value
{
	return [self findWithSqlWithParameters:[NSString stringWithFormat:@"select * from %@ where %@ = ?", [self tableName], column], value, nil];
}

+ (NSArray *) findByColumn: (NSString *) column unsignedIntegerValue: (NSUInteger) value
{
	return [self findByColumn:column value: [NSNumber numberWithUnsignedInteger:value]];
}

+ (NSArray *) findByColumn: (NSString *) column integerValue: (NSInteger) value
{
	return [self findByColumn:column value: [NSNumber numberWithInteger:value]];
}

+ (NSArray *) findByColumn: (NSString *) column doubleValue: (double) value
{
	return [self findByColumn:column value: [NSNumber numberWithDouble:value]];
}

+ (id) find: (NSUInteger) primaryKey 
{
	NSArray *results = [self findByColumn: @"primaryKey" unsignedIntegerValue: primaryKey];
	
	if([results count] < 1)
	{
		return nil;
	}
	return [results objectAtIndex:0];
}

+ (NSArray *) findAll
{
	return [self findWithSql: [NSString stringWithFormat:@"select * from %@", [self tableName]]];
}

@end
