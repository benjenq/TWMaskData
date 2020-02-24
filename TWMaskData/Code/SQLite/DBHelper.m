//
//  DBHelper.m
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import "DBHelper.h"
#import "Extensions.h"

@implementation DBHelper
@synthesize database = _database;

static DBHelper *theDBZipCodeInstance;
// 取得資料庫輔助物件的 singleton
+ (DBHelper *) shareInstance{

    @synchronized(theDBZipCodeInstance){
        if (!theDBZipCodeInstance) {
            theDBZipCodeInstance = [[DBHelper alloc] init];
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[DBHelper databasePath]]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle].bundlePath stringByAppendingPathComponent:NSLocalizedString(@"DATABASE_NAME", @"EmptyDB.db")]
                                                    toPath:[DBHelper databasePath]
                                                     error:&error];
            
        }
        [theDBZipCodeInstance openDatabase];
    }
    return theDBZipCodeInstance;
    
}

+(NSString *)databasePath{
    return [[UIApplication GetDocumentPath] stringByAppendingPathComponent:NSLocalizedString(@"DATABASE_NAME", @"EmptyDB.db")];
}

- (sqlite3 *) openDatabase{
    if(!_database){
        if(sqlite3_open([[DBHelper databasePath] UTF8String], &_database) == SQLITE_OK) {
            NSLog(@"Opening database [%@]...",NSLocalizedString(@"DATABASE_NAME", @"ZIPCode.db"));
            return _database;
        }else{
            return nil;
        }
    }else{
        //NSLog(@"Return database ...");
        return _database;
    }
}

// 關閉資料庫
- (void) closeDatabase
{
    if(_database){
        NSLog(@"close Database ...");
        sqlite3_close(_database);
        _database = nil;
    }
}

+ (void)BEGINTRANSACTION{
    [[DBHelper shareInstance] BEGINTRANSACTION];
}
+ (void)ENDTRANSACTION{
    [[DBHelper shareInstance] ENDTRANSACTION];
}

- (void)BEGINTRANSACTION{
    char *ERROR;
    sqlite3_exec(_database, "PRAGMA synchronous = OFF", NULL, NULL, &ERROR);
    sqlite3_exec(_database, "PRAGMA journal_mode = MEMORY", NULL, NULL, &ERROR);
    sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &ERROR);
    
    /*
    if (sqlite3_exec(_database, "BEGIN TRANSACTION", NULL, NULL, &ERROR)!=SQLITE_OK){
        NSLog(@"ERROR:BEGIN TRANSACTION");
    }*/
}

- (void)ENDTRANSACTION{
    char *ERROR;
    sqlite3_exec(_database, "END TRANSACTION", NULL, NULL, &ERROR);
    sqlite3_exec(_database, "PRAGMA journal_mode = DELETE", NULL, NULL, &ERROR);
    sqlite3_exec(_database, "PRAGMA synchronous = NORMAL", NULL, NULL, &ERROR);
    /*
    if (sqlite3_exec(_database, "END TRANSACTION", NULL, NULL, &ERROR)!=SQLITE_OK){
        NSLog(@"ERROR:END TRANSACTION");
    }*/
    
}


// 資料總數
+ (NSUInteger) intForSQL:(const char *) sql{
    return (NSUInteger)[[DBHelper shareInstance] intForSQL:sql];
}

- (int) intForSQL:(const char *) sql
{
    sqlite3_stmt *stm;
    int count = 0;
    @try{
        if(sqlite3_prepare_v2(_database,sql,-1,&stm,NULL) == SQLITE_OK) {
            if( sqlite3_step(stm)==SQLITE_ROW ){
                count = sqlite3_column_int(stm,0);
            }
        }
    }@catch(id exception){
    }@finally {
        // 釋放敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return count;
}

+ (NSString *) stringFromSQL:(const char *) sql{
    return (NSString *)[[DBHelper shareInstance] stringFromSQL:sql];
}

- (NSString *) stringFromSQL:(const char *) sql{
    
    sqlite3_stmt *stm;
    NSString *str = @"";
    @try{
        if(sqlite3_prepare_v2(_database,sql,-1,&stm,NULL) == SQLITE_OK) {
            if( sqlite3_step(stm)==SQLITE_ROW ){
                str = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 0)];
            }
        }
    }@catch(id exception){
    }@finally {
        // 釋放敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return str;
    
}

+ (BOOL)executeSQL:(const char *)sql{
    return [[DBHelper shareInstance] executeSQL:sql];
}

// 執行SQL語法
- (BOOL)executeSQL:(const char *)sql{
    sqlite3_stmt *stm;
    BOOL isExecSuccess = NO;
    @try{
        if(sqlite3_prepare_v2(_database,sql,-1,&stm,NULL) == SQLITE_OK) {
            if(sqlite3_step(stm) ==SQLITE_DONE){
                isExecSuccess = YES;
            }
        }
    }@catch(id exception){
    }@finally {
        // 釋放敘述
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return isExecSuccess;
}


@end
