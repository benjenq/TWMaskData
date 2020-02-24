//
//  MaskDataAPI.m
//  MaskData
//
//  Created by administrator on 2020/2/7.
//

#import "MaskDataAPI.h"
#import "jsonURL.h"
#import "Extensions.h"
#import "DBHelper.h"

@interface MaskDataAPI (){
    
}

@property (nonatomic, retain) dispatch_queue_t APIQueue;

@end

@implementation MaskDataAPI

static MaskDataAPI *theInstance = nil;

+ (instancetype)shareInstance{
    @synchronized (theInstance) {
        if (theInstance == nil) {
            theInstance = [[MaskDataAPI alloc] init];
        }
    }
    return theInstance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        NSLog(@"MaskDataAPI APIQueue Created");
        self.APIQueue = dispatch_queue_create("APIQueue", NULL);
    }
    return self;
}

+ (dispatch_queue_t)queue{
    return [MaskDataAPI shareInstance].APIQueue;
}

+ (void)getMaskGataWithWriteDB:(BOOL)writeDB WithCompletion:(void(^)(BOOL success,NSArray <MaskData *> *array))completion{
    __block NSMutableArray <MaskData *>*result = [[NSMutableArray alloc] init] ;
    //NSLog(@"開始抓取 Mask Data...");
    [jsonURL jsonFromURL:[self Url] method:httpMethodIsGET completion:^(BOOL success, NSString *errorStr, NSString *resultJsonString) {
        //NSLog(@"%@",resultJsonString);
        NSArray <NSString *>*rowStr = [resultJsonString componentsSeparatedByString:[NSString stringWithFormat:@"%c%c",13,10]];
        [rowStr enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                return ;
            }
            NSArray <NSString *>*cellStr = [obj componentsSeparatedByString:@","];
            if([cellStr count] >= 2){
                MaskData *item = [[MaskData alloc] initWithPharmacyID:[cellStr objectAtIndex:0]];
                item.pharmacyid = [cellStr objectAtIndex:0];
                item.name = [cellStr objectAtIndex:1];
                NSString *_addr = [NSString toHalhNumberStr:[cellStr objectAtIndex:2]];
                if([item.addr isEqualToString:@""] || ![item.addr isEqualToString:_addr] ){
                    item.addr = _addr;
                }
                if([item.telno isEqualToString:@""]){
                    item.telno = [cellStr objectAtIndex:3];
                }
                item.maskadult =  [[cellStr objectAtIndex:4] integerValue];
                item.maskchild =  [[cellStr objectAtIndex:5] integerValue];
                item.lastdatetime = [[cellStr objectAtIndex:6] stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
                [result addObject:item];
                
            }
            else{
                return ;
            }
        }];
    }];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"pharmacyid" ascending:YES];
    [result sortUsingDescriptors:[NSArray arrayWithObjects:sort, nil]];
    if([result count] > 0){
        if(writeDB){
            NSLog(@"更新資料庫[ %lu 筆]...",(unsigned long)[result count]);
            [DBHelper BEGINTRANSACTION];
            [result enumerateObjectsUsingBlock:^(MaskData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [obj writeMaskRemainderDB];
                [obj writePharmacyDB];
            }];
            [DBHelper ENDTRANSACTION];
            NSLog(@"更新資料庫完成!");
        }        
        completion(YES, result);
    }
    else{
        completion(NO, result);
    }
}
+ (NSString *)Url{
    return NSLocalizedString(@"APIURL", @"APIURL");
}

@end
