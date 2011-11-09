//
//  ISDatabase.h
//  GroceryList
//
//  Created by Dylan Bruzenak on 6/16/09.
//  Copyright 2009 Dylan Bruzenak. All rights reserved.
//

#import <sqlite3.h>

@interface ISDatabase : NSObject {
	NSString *pathToDatabase;
	BOOL logging;
	sqlite3 *database;
}

@property (nonatomic, retain) NSString *pathToDatabase;
@property (nonatomic) BOOL logging;

- (id) initWithPath: (NSString *) filePath;
- (id) initWithFileName: (NSString *) fileName;
- (NSArray *) executeSql: (NSString *) sql;
- (NSArray *) executeSqlWithParameters: (NSString *) sql, ...;
- (NSArray *) executeSql: (NSString *) sql withParameters: (NSArray *) parameters;
- (NSArray *) executeSql: (NSString *) sql withParameters: (NSArray *) parameters withClassForRow: (Class) rowClass;
- (NSArray *) tableNames;
- (NSArray *) columnsForTableName: (NSString *) tableName;
- (void) beginTransaction;
- (void) commit;
- (void) rollback;
- (NSUInteger) lastInsertRowId;
@end
