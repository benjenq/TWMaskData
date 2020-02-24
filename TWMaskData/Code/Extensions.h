//
//  Extensions.h
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (beExtensions)
+ (NSString *)GetBundlePath;
+ (NSString *)GetDocumentPath;
+ (NSString *)GetCachePath;
+ (NSString *)GettmpPath;

@end

@interface NSString (NSStringExtension)

+ (NSString *)toHalhNumberStr:(NSString *)str;
+ (NSString *)twAddressConvert:(NSString *)str;

+ (NSString *)distanceString:(CGFloat)meter;

@end

@interface UIColor (extension)
+ (UIColor *)AnnotationGreen;
@end

NS_ASSUME_NONNULL_END
