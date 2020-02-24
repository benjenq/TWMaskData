//
//  CallOutPharmacy.h
//  MaskData
//
//  Created by Administrator on 2020/2/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class MaskData;
@class MaskMapViewController;
@interface CallOutViewPharmacy : UIView

+ (instancetype)viewtWithMaskData:(MaskData *)maskdata viewcontroller:(UIViewController *)vc;
- (void)setStockColor:(UIColor *)color;
- (void)setStockTextColor:(UIColor *)color;
@end

NS_ASSUME_NONNULL_END
