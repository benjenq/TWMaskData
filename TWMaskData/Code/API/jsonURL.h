//
//  jsonURL.h
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jsonURL : NSObject

typedef NS_ENUM(NSUInteger,httpMethod)
{
    httpMethodIsPOST = 0,
    httpMethodIsGET = 1,
    httpMethodIsPUT = 2
};

+(void)jsonFromURL:(NSString *)urlStr method:(httpMethod)method completion:(void(^)(BOOL success,NSString *errorStr, NSString *resultJsonString))completion;

@end
