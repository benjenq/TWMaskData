//
//  MaskDataAPI.h
//  MaskData
//
//  Created by administrator on 2020/2/7.
//

#import <Foundation/Foundation.h>
#import "MaskData.h"

NS_ASSUME_NONNULL_BEGIN
@interface MaskDataAPI : NSObject

+ (void)getMaskGataWithWriteDB:(BOOL)writeDB WithCompletion:(void(^)(BOOL success,NSArray <MaskData *> *array))completion;

+ (dispatch_queue_t)queue;
@end

NS_ASSUME_NONNULL_END
