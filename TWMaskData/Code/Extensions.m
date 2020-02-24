//
//  Extensions.m
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import "Extensions.h"

@implementation UIApplication (beExtensions)

+ (NSString *)GetBundlePath{
    return [[NSBundle mainBundle] bundlePath];
}

+ (NSString *)GetDocumentPath{
    return [NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0]];
}
+ (NSString *)GetCachePath{
    return [NSString stringWithFormat:@"%@",[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0]];
}
+ (NSString *)GettmpPath{
    return [NSString stringWithFormat:@"%@",NSTemporaryDirectory()];
}

@end



@implementation NSString (NSStringExtension)

+ (NSString *)toHalhNumberStr:(NSString *)str{
    NSString *resultStr = [[[[[[[[[[[[str stringByReplacingOccurrencesOfString:@"０" withString:@"0"]
                                     stringByReplacingOccurrencesOfString:@"１" withString:@"1"]
                                    stringByReplacingOccurrencesOfString:@"２" withString:@"2"]
                                   stringByReplacingOccurrencesOfString:@"３" withString:@"3"]
                                  stringByReplacingOccurrencesOfString:@"４" withString:@"4"]
                                 stringByReplacingOccurrencesOfString:@"５" withString:@"5"]
                                stringByReplacingOccurrencesOfString:@"６" withString:@"6"]
                               stringByReplacingOccurrencesOfString:@"７" withString:@"7"]
                              stringByReplacingOccurrencesOfString:@"８" withString:@"8"]
                             stringByReplacingOccurrencesOfString:@"９" withString:@"9"]
                            stringByReplacingOccurrencesOfString:@"－" withString:@"-"]
                           stringByReplacingOccurrencesOfString:@"–" withString:@"-"];
    
    return resultStr;
}

+ (NSString *)twAddressConvert:(NSString *)str{
    NSString *resultStr =  [[[[[NSString toHalhNumberStr:str] stringByReplacingOccurrencesOfString:@"臺北" withString:@"台北"]
                              stringByReplacingOccurrencesOfString:@"臺中" withString:@"台中"]
                             stringByReplacingOccurrencesOfString:@"臺南" withString:@"台南"]
                            stringByReplacingOccurrencesOfString:@"臺東" withString:@"台東"];
    return resultStr;
    
}

+ (NSString *)distanceString:(CGFloat)meter{
    if(meter < 0){
        return @"距離未知...";
    }
    else if(meter < 1000){
        return [NSString stringWithFormat:@"%.0f 公尺",meter];
    }
    else if(meter < 10000){
        return [NSString stringWithFormat:@"%.3f 公里",meter/1000];
    }
    else if(meter < 100000){
        return [NSString stringWithFormat:@"%.2f 公里",meter/1000];
    }
    else{
        return [NSString stringWithFormat:@"%.1f 公里",meter/1000];
    }
}



@end

@implementation UIColor (extension)
+ (UIColor *)AnnotationGreen{
    return [UIColor colorWithRed:(CGFloat)31.0/255.0 green:(CGFloat)122.0/255.0 blue:(CGFloat)55.0/255.0 alpha:1.0];
}

@end
