//
//  AnnotationPharmacy.h
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN
@class MaskData;
@interface AnnotationPharmacy : NSObject
@property (nonatomic, readwrite, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSString *subtitle;
@property (nonatomic,strong) MaskData *maskdata; //assign 會導致錯誤，因為 VC 的 Array 會自動釋放，所以要 retain
@property (nonatomic) BOOL isOnMap;

- (instancetype)initWithCoords:(CLLocationCoordinate2D) coords;
- (instancetype)initWithMaskData:(MaskData *) maskdata;

@end

NS_ASSUME_NONNULL_END
