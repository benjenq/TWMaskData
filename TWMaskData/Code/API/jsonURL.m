//
//  jsonURL.m
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import "jsonURL.h"

@implementation jsonURL

+(void)jsonFromURL:(NSString *)urlStr method:(httpMethod)method completion:(void(^)(BOOL success,NSString *errorStr, NSString *resultJsonString))completion{
    
    //NSString *encodeUrl = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; //API_DEPRECATED
    NSString *encodeUrl = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]; //iOS9
    //NSLog(@"encodeUrl = %@",encodeUrl);
    NSURL *aUrl = [NSURL URLWithString:encodeUrl];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5.0];
    
    if (method == httpMethodIsGET) {
        [request setHTTPMethod:@"GET"];
    }
    else if (method == httpMethodIsPOST) {
        [request setHTTPMethod:@"POST"];
    }
    else if (method == httpMethodIsPUT) {
        [request setHTTPMethod:@"PUT"];
    }
    else{
        [request setHTTPMethod:@"GET"];
    }

    /* iOS8 API_DEPRECATED
    NSHTTPURLResponse *response = NULL;
    NSError *err = nil;
    NSData *htmlData= [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err]; //API_DEPRECATED("Use [NSURLSession dataTaskWithRequest:completionHandler:] (see NSURLSession.h", macos(10.3,10.11), ios(2.0,9.0), tvos(9.0,9.0)) __WATCHOS_PROHIBITED;
    */

    __block NSData *htmlData = nil;
    __block NSError *err = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        htmlData = data;
        err = error;
        //NSLog(@"response=%@",response);
        dispatch_semaphore_signal(semaphore);
    }] resume];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    if (err !=  nil) {
        NSLog(@"error=%@",err);
        completion(NO,[err localizedDescription],@"");
        return ;
    }
    
    if (htmlData == nil) {
        completion(NO,@"resposeData is NULL",@"");
        return ;
    }
    
    
    NSString *resultStr = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding] ;
    //NSLog(@"htmlString=%@",resultStr);
    
    completion(YES,@"",resultStr);
}

@end

