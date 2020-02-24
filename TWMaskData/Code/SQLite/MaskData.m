//
//  MaskData.m
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import "MaskData.h"
#import "DBHelper.h"
#import <MapKit/MapKit.h>
#import "Extensions.h"
@implementation MaskData

- (instancetype)init{
    self = [super init];
    if (self) {
        self.pharmacyid = @"";
        self.name = @"";
        self.type = @"";
        self.telno = @"";
        self.addr = @"";
        self.expiredate = @"";
        self.visittime = @"";
        self.latitude = -1;
        self.longitude = -1;
        self.maskadult = 0;
        self.maskchild = 0;
        self.lastdatetime = @"";
    }
    return self;
}
- (instancetype)initWithPharmacyID:(NSString *)inPharmacyid{
    self = [self init];
    if (!self) {
        return nil;
    }
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *db = [dbh openDatabase];
    sqlite3_stmt *stm;
    NSString *l_sql = @"SELECT pharmacyid, name, type, telno, addr, expiredate, visittime, latitude, longitude, maskadult, maskchild, lastdatetime FROM maskdata_v WHERE pharmacyid = ? ;" ;
    @try {
        if(sqlite3_prepare_v2(db, [l_sql UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_text(stm,1,[inPharmacyid UTF8String],-1,SQLITE_STATIC);
            while(sqlite3_step(stm) ==SQLITE_ROW){
                self.pharmacyid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 0)];
                self.name = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 1)];
                self.type = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 2)];
                self.telno = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 3)];
                self.addr = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 4)];
                self.expiredate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 5)];
                self.visittime = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 6)];
                if([self.visittime isEqualToString:@""]){
                    self.visittime = @"無資訊";
                }
                self.latitude = sqlite3_column_double(stm, 7);
                self.longitude = sqlite3_column_double(stm, 8);
                
                self.maskadult = sqlite3_column_int(stm, 9);
                self.maskchild = sqlite3_column_int(stm, 10);

                self.lastdatetime = sqlite3_column_text(stm, 11) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 11)] : @"";
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"initWithPharmacyID error:%@",exception.description);
    } @finally {
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return self;
}

#pragma mark - 口罩
- (BOOL)writeMaskRemainderDB{
    return [self addMaskRemainder];
}

- (BOOL)addMaskRemainder{
    BOOL success = NO;
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *db = [dbh openDatabase];
    sqlite3_stmt *stm;
    NSString *l_sql = @"INSERT OR REPLACE INTO maskremainder (pharmacyid, maskadult, maskchild, lastdatetime)  \
    VALUES(?,?,?,?) ;";
    @try {
        if(sqlite3_prepare_v2(db, [l_sql UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_text(stm,1,[self.pharmacyid UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_int(stm, 2, (int)self.maskadult);
            sqlite3_bind_int(stm, 3, (int)self.maskchild);
            sqlite3_bind_text(stm,4,[self.lastdatetime UTF8String],-1,SQLITE_STATIC);
            if(sqlite3_step(stm) ==SQLITE_DONE){
                success = YES;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"addMaskRemainder error:%@",exception.description);
    } @finally {
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return success;
    
}

#pragma mark - 藥局
- (BOOL)writePharmacyDB{
    return [self addPharmacy];
}

- (BOOL)addPharmacy{
    BOOL success = NO;
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *db = [dbh openDatabase];
    sqlite3_stmt *stm;
    NSString *l_sql = @"INSERT OR REPLACE INTO pharmacy (pharmacyid, name, type, telno, addr, expiredate, visittime, latitude, longitude)  \
    VALUES(?,?,?,?,?,?,?,?,?) ;";
    @try {
        if(sqlite3_prepare_v2(db, [l_sql UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            sqlite3_bind_text(stm,1,[self.pharmacyid UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,2,[self.name UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,3,[self.type UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,4,[self.telno UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,5,[self.addr UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,6,[self.expiredate UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_text(stm,7,[self.visittime UTF8String],-1,SQLITE_STATIC);
            sqlite3_bind_double(stm, 8, self.latitude);
            sqlite3_bind_double(stm, 9, self.longitude);

            if(sqlite3_step(stm) ==SQLITE_DONE){
                success = YES;
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"updateCoordinate error:%@",exception.description);
    } @finally {
        if( stm!=nil )
            sqlite3_finalize(stm);
    }
    return success;
}

#pragma mark - GeoCode 地址轉座標
- (void)updateCoordinate:(void(^)(BOOL success,MaskData *maskdata, GeoDecodeFrom geodecodefrom))completion{
    if([self isInTaiwan]){
        NSLog(@"%@-%@ (%f,%f) 在台灣範圍內，不處理...",self.name,self.addr,self.latitude,self.longitude);
        completion(NO,self,GeoDecodeFailure);
        return;
    }
    NSString *correctAddr = [NSString twAddressConvert:self.addr];
    NSLog(@"%@-%@ (%f,%f) Apple GeoCode 解析座標...",self.name,correctAddr,self.latitude,self.longitude);
    CLGeocoder *geo = [[CLGeocoder alloc] init] ;
    [geo geocodeAddressString:correctAddr completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if(error != nil){
            NSLog(@"%@-%@ 解析座標...錯誤: %@ ",self.name,correctAddr,error.localizedDescription);
            return;
        }
        [placemarks enumerateObjectsUsingBlock:^(CLPlacemark * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx >0){
                return;
            }
            if(![MaskData coordinateIsInTaiwan:obj.location.coordinate]){
                NSLog(@"%@-%@ Apple GeoCode 解析座標結果 (%f,%f) 有誤（不在台灣範圍）",self.name,correctAddr,obj.location.coordinate.latitude,obj.location.coordinate.longitude);
                return;
            }
            else{
                self.latitude = obj.location.coordinate.latitude;
                self.longitude = obj.location.coordinate.longitude;
                NSLog(@"%@-%@ Apple GeoCode 解析座標結果： %f,%f",self.name,correctAddr,self.latitude,self.longitude);
                [self writePharmacyDB];
                [self writeMaskRemainderDB];
                completion(YES,self,GeoDecodeFromApple);
            }
        }];
    }];
}

#pragma mark - 資料判定
#pragma mark 藥房座標
- (BOOL)isInTaiwan{
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    if((coor.latitude >20 && coor.latitude <=27) && (coor.longitude >110 && coor.longitude <=130)){
        return YES;
    }
    else{
        return NO;
    }
}

+ (BOOL)coordinateIsInTaiwan:(CLLocationCoordinate2D)coor{
    if((coor.latitude >20 && coor.latitude <=27) && (coor.longitude >110 && coor.longitude <=130)){
        return YES;
    }
    else{
        return NO;
    }
}

#pragma mark 庫存狀態
/*
 typedef NS_ENUM(NSInteger,StockStatus){
     StockStatusIsOutStock = 0,
     StockStatusIsOnlyChild = 1,
     StockStatusIsNotEnough = 2,
     StockStatusIsEnough = 3
 };
 */
- (StockStatus)stockstatus{
    if(self.maskadult <=0 && self.maskchild <=0){
        return StockStatusIsOutStock;
    }
    else if (self.maskadult <=3 && self.maskchild > 0){
        return StockStatusIsOnlyChild;
    }
    else if (self.maskadult <=15 && (CGFloat)self.maskadult + 0.03*((CGFloat)self.maskchild) <= 25.0f ){
        return StockStatusIsNotEnough;
    }
    else{
        return StockStatusIsEnough;
    }
}



#pragma mark -

+ (NSArray <MaskData *> *)DatasWithType:(DataType)datatype{
    NSMutableArray *result = [[NSMutableArray alloc] init] ;
    NSString *l_sql = @"SELECT pharmacyid,addr FROM maskdata_v WHERE 1=1 ORDER BY pharmacyid ; " ;
    DBHelper *dbh=[DBHelper shareInstance];
    sqlite3 *db = [dbh openDatabase];
    sqlite3_stmt *stm;
    @try {
        if(sqlite3_prepare_v2(db, [l_sql UTF8String], -1, &stm, NULL)== SQLITE_OK) {
            while(sqlite3_step(stm) == SQLITE_ROW){
                NSString *pid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(stm, 0)];
                MaskData *item = [[MaskData alloc] initWithPharmacyID:pid];
                switch (datatype) {
                    case DataTypeIsAll:
                        [result addObject:item];
                        break;
                    case DataTypeIsHasLocation:
                        if([item isInTaiwan]){
                            [result addObject:item];
                        }
                        break;
                    case DataTypeIsNoLocation:
                        if(![item isInTaiwan]){
                            [result addObject:item];
                        }
                        break;
                    default:
                        break;
                }
            }
        }
    } @catch (NSException *exception) {
        NSLog(@"allDatas error:%@",exception.description);
    } @finally {
        
    }
    NSLog(@"資料庫資料筆數:%lu",(unsigned long)[result count]);
    return (NSArray *)result;
}

-(void)dealloc{
    //NSLog(@"<%p>%@[%@] dealloc",self,self.name,[self class].description);
   
}

@end
