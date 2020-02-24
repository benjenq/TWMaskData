//
//  CallOutPharmacy.m
//  MaskData
//
//  Created by Administrator on 2020/2/9.
//

#import "CallOutViewPharmacy.h"
#import "MaskData.h"
#import "ViewController.h"
@interface CallOutViewPharmacy (){
    IBOutlet UILabel *lbPharmacyId;
    IBOutlet UILabel *lbStockStatus;
    IBOutlet UILabel *lbMaskAudlt;
    IBOutlet UILabel *lbMaskChild;
    IBOutlet UILabel *lbDistance;
    IBOutlet UILabel *lbAddrTitle;
    IBOutlet UILabel *lbAddr;
    IBOutlet UILabel *lbTel;
    IBOutlet UITextView *tbVisitTime;
    IBOutlet UILabel *lbLastDatetime;
    
    CGFloat frameWidth;
    CGFloat frameHeight;
}

@property (nonatomic,assign) MaskData *maskdata;
@property (nonatomic,assign) ViewController *superVC;

@property (nonatomic,retain) NSLayoutConstraint *widthConstraint;
@property (nonatomic,retain) NSLayoutConstraint *heightConstraint;


@end

@implementation CallOutViewPharmacy

+ (instancetype)viewtWithMaskData:(MaskData *)maskdata viewcontroller:(UIViewController *)vc{
    CallOutViewPharmacy *v = [[[NSBundle mainBundle] loadNibNamed:@"CallOutViewPharmacy" owner:self options:nil] firstObject];
    v.translatesAutoresizingMaskIntoConstraints = NO;
    v.maskdata = maskdata;
    v.superVC = (ViewController *)vc;
    [v firstConstraint];
    [v bindValue];
    return v;
}

- (void)firstConstraint{
    tbVisitTime.backgroundColor = [UIColor clearColor];
    frameWidth = self.frame.size.width;
    frameHeight = self.frame.size.height;
    [self renewAllConstraint];
}

- (void)renewAllConstraint{
    
    //[self removeConstraints:self.constraints];
    
   
    self.widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                        attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:nil
                                                        attribute:NSLayoutAttributeNotAnAttribute
                                                       multiplier:1
                                                         constant:frameWidth];
    
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:nil
                                                         attribute:NSLayoutAttributeNotAnAttribute
                                                        multiplier:1
                                                          constant:frameHeight];
    
    
    
    [self addConstraint:self.widthConstraint];
    [self addConstraint:self.heightConstraint];
}
/*
typedef NS_ENUM(NSInteger,StockStatus){
    StockStatusIsOutStock = 0,
    StockStatusIsOnlyChild = 1,
    StockStatusIsNotEnough = 2,
    StockStatusIsEnough = 3
};
*/
- (void)bindValue{
    lbPharmacyId.text = self.maskdata.pharmacyid;
    
    switch (self.maskdata.stockstatus) {
        case StockStatusIsOutStock:
            lbStockStatus.text = @"無庫存";
            break;
        case StockStatusIsOnlyChild:
            lbStockStatus.text = @"僅剩兒童";
            break;
        case StockStatusIsNotEnough:
            lbStockStatus.text = @"庫存吃緊";
            break;
        case StockStatusIsEnough:
            lbStockStatus.text = @"庫存正常";
            break;
        default:
            break;
    }
    
    lbMaskAudlt.text = [NSString stringWithFormat:@"成人：%ld",(long)self.maskdata.maskadult];
    lbMaskChild.text = [NSString stringWithFormat:@"兒童：%ld",(long)self.maskdata.maskchild];
    lbAddr.text = self.maskdata.addr;
    lbTel.text = self.maskdata.telno;
    tbVisitTime.text = self.maskdata.visittime;
    lbLastDatetime.text = self.maskdata.lastdatetime;
    //https://stackoverflow.com/questions/1054558/vertically-align-text-to-top-within-a-uilabel
    [lbAddr setNumberOfLines:0];
    [lbAddr sizeToFit];
    [lbAddrTitle setNumberOfLines:0];
    [lbAddrTitle sizeToFit];
}
- (void)setStockColor:(UIColor *)color{
    lbStockStatus.backgroundColor = color;    
}
- (void)setStockTextColor:(UIColor *)color{
    lbStockStatus.textColor = color;
}

- (void)removeFromSuperview{
    [super removeFromSuperview];
}

#pragma mark -

-(IBAction)shareAction:(UIButton *)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *shareContent = [NSString stringWithFormat:@"藥局：%@\n地址：%@\n電話：%@\n%@，%@\n\n時間：%@",
                                  self.maskdata.name,self->lbAddr.text,self->lbTel.text,self->lbMaskAudlt.text,self->lbMaskChild.text,self->lbLastDatetime.text];
                
        NSArray *shareItemArray = [NSArray arrayWithObjects:shareContent, nil];
        
        UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:shareItemArray applicationActivities:nil];
        
        //排除（excluded）可分享的類型
        activityVC.excludedActivityTypes = @[
        UIActivityTypePostToWeibo,
        UIActivityTypeMail,
        UIActivityTypeMessage,
        UIActivityTypeAssignToContact,
        UIActivityTypeAddToReadingList,
        UIActivityTypePostToFlickr,
        UIActivityTypePostToVimeo,
        UIActivityTypePostToTencentWeibo,
        UIActivityTypeOpenInIBooks];
        //類型 UIActivityTypeSaveToCameraRoll 需在 Info.plist 加入 NSPhotoLibraryAddUsageDescription - 字串的權限
        activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
            NSLog(@"activityType = %@",activityType);
            //NSLog(@"completed = %i",completed);
            //NSLog(@"returnedItems = %@",returnedItems);
            //NSLog(@"activityError = %@",activityError.localizedDescription);
        };
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
            activityVC.modalPresentationStyle = UIModalPresentationPopover;
            activityVC.popoverPresentationController.sourceView = sender;
            [self.superVC presentViewController:activityVC animated:YES completion:nil];
        }
        else{
            [self.superVC presentViewController:activityVC animated:YES completion:nil];
        }
    
    });
}

-(IBAction)navigate:(UIButton *)sender{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
        NSString *urlString = [[NSString stringWithFormat:@"comgooglemaps://?daddr=%@&directionsmode=bicycling",
                                self.maskdata.addr] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success){}];
    }
    else{
        NSString *urlString = [[NSString stringWithFormat:@"http://maps.apple.com/?daddr=%f,%f&directionsmode=bicycling",
        self.maskdata.latitude,self.maskdata.longitude] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success){}];
    }
}

-(IBAction)callTel:(UIButton *)sender{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]){
        
        NSString *urlString = [[NSString stringWithFormat:@"tel://%@",
                                [self.maskdata.telno stringByReplacingOccurrencesOfString:@" " withString:@""]]
                               stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString] options:@{} completionHandler:^(BOOL success){}];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)dealloc{
    //NSLog(@"<%p>%@(%@) dealloc",self, [self class].description, self.maskdata.name);
}

@end
