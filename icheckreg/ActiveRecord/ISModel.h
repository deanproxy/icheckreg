//
//  ISModel.h
//  GroceryList
//
//  Created by Dylan Bruzenak on 6/18/09.
//  Copyright 2009 Dylan Bruzenak. All rights reserved.
//

@class ISDatabase;

@interface ISModel : NSObject {
	NSUInteger primaryKey;
	BOOL savedInDatabase;
}

@property (nonatomic) NSUInteger primaryKey;
@property (nonatomic) BOOL savedInDatabase;

+ (void) setDatabase: (ISDatabase *) newDatabase;
+ (ISDatabase *) database;
- (void) save;
- (void) delete;
+ (NSArray *) findWithSql: (NSString *) sql withParameters: (NSArray *) parameters;
+ (NSArray *) findWithSqlWithParameters: (NSString *) sql, ...;
+ (NSArray *) findWithSql: (NSString *) sql;
+ (NSArray *) findByColumn: (NSString *) column value: (id) value;
+ (NSArray *) findByColumn: (NSString *) column unsignedIntValue: (NSUInteger) value;
+ (NSArray *) findByColumn: (NSString *) column intValue: (NSInteger) value;
+ (NSArray *) findByColumn: (NSString *) column doubleValue: (double) value;
+ (id) find: (NSUInteger) primaryKey;
+ (NSArray *) findAll;
@end
