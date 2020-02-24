//
//  AnnotationPharmacy.m
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import "AnnotationPharmacy.h"
#import "MaskData.h"

@implementation AnnotationPharmacy

- (instancetype)initWithCoords:(CLLocationCoordinate2D)coords{
    self = [super init];
    if (self != nil) {
        self.coordinate = coords;
        self.title = @"";
        self.subtitle = @"";
        self.maskdata = [[MaskData alloc] init] ;
        self.isOnMap = NO;
    }
    
    return self;
}

- (instancetype)initWithMaskData:(MaskData *) maskdata{
    self = [super init];
    if (self != nil) {
        self.maskdata = maskdata;
        self.coordinate = CLLocationCoordinate2DMake(self.maskdata.latitude, self.maskdata.longitude);
        self.title = self.maskdata.name;
        self.subtitle = [NSString stringWithFormat:@"成人：%li, 兒童：%li",(long)self.maskdata.maskadult,(long)self.maskdata.maskchild];
        self.isOnMap = NO;
    }
    return self;
}

-(void)dealloc{
    //NSLog(@"<%p>%@ dealloc",self,[self class].description);
}

@end
