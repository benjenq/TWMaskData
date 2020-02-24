//
//  MaskRemainder.h
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

@interface MaskData : NSObject

typedef NS_ENUM(NSInteger, DataType) {
    DataTypeIsAll = 0,
    DataTypeIsHasLocation = 1,
    DataTypeIsNoLocation = 2
};

typedef NS_ENUM(NSInteger,StockStatus){
    StockStatusIsOutStock = 0,
    StockStatusIsOnlyChild = 1,
    StockStatusIsNotEnough = 2,
    StockStatusIsEnough = 3
};

typedef NS_ENUM(NSInteger,GeoDecodeFrom){
    GeoDecodeFailure = -1,
    GeoDecodeFromApple = 0,
    GeoDecodeFromGoogle = 1
};

@property (nonatomic,retain) NSString *pharmacyid; //醫事機構代碼
@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *telno;
@property (nonatomic,retain) NSString *addr;
@property (nonatomic,retain) NSString *expiredate;
@property (nonatomic,retain) NSString *visittime;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;

@property (nonatomic) NSInteger maskadult;
@property (nonatomic) NSInteger maskchild;
@property (nonatomic,retain) NSString *lastdatetime;
@property (nonatomic,getter=stockstatus) StockStatus stockstatus;

- (instancetype)initWithPharmacyID:(NSString *)inPharmacyid;

- (BOOL)writeMaskRemainderDB;

- (BOOL)writePharmacyDB;

- (void)updateCoordinate:(void(^)(BOOL success,MaskData *maskdata, GeoDecodeFrom geodecodefrom))completion;

- (BOOL)isInTaiwan;

- (StockStatus)stockstatus;



+ (NSArray <MaskData *> *)DatasWithType:(DataType)datatype;

@end

NS_ASSUME_NONNULL_END
