//
//  ViewController.m
//  TWMaskData
//
//  Created by Administrator on 2020/2/23.
//  Copyright © 2020 benjenq. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>
#import "MaskDataAPI.h"
#import "AnnotationPharmacy.h"
#import "CallOutViewPharmacy.h"
#import "Extensions.h"

@interface ViewController (){
    IBOutlet MKMapView *_mapView;
    IBOutlet UIActivityIndicatorView *_actLoading;
    IBOutlet UIButton *btnCurrentLocation;
    IBOutlet UIBarButtonItem *btnRefresh;
    
    NSInteger currentAnnCount;
    NSInteger maxAnnCount;
    
    BOOL regionIsChanging;
    BOOL mapQueueIsBusy;
}

@property (nonatomic, retain) dispatch_queue_t MapQueue;
@property (nonatomic, retain) NSMutableArray <AnnotationPharmacy *> *annonations;
@property (nonatomic,retain) NSArray <UIColor *> *stockBackGroundColors;
@property (nonatomic,retain) NSArray <UIColor *> *stockTextColors;

@property (nonatomic,retain) CallOutViewPharmacy *annonationCalloutView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appReturnsActive) name:UIApplicationDidBecomeActiveNotification object:nil];

    self.MapQueue = dispatch_queue_create("MapQueue", NULL);

    regionIsChanging = NO;
    mapQueueIsBusy = NO;
    currentAnnCount = 0;
    maxAnnCount = 250;
    
    self.title = NSLocalizedString(@"NAVIGATION_TITLE", @"口罩之亂地圖");

    [MaskDataAPI queue];
    if(!self.annonations){
        self.annonations = [[NSMutableArray alloc] init];
    }
    [self annonationSettings];
    if (@available(iOS 11.0, *)) {
        [_mapView registerClass:[MKMarkerAnnotationView class] forAnnotationViewWithReuseIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier]; //MKMapViewDefaultAnnotationViewReuseIdentifier
    } else {
        // Fallback on earlier versions
    }
    [_mapView setDelegate:(id<MKMapViewDelegate> _Nullable)self];
    [_mapView setShowsScale:YES]; //NS_AVAILABLE(10_10, 9_0);
    
    //set region center
    CLLocationCoordinate2D theCenter = CLLocationCoordinate2DMake(23.76754884, 120.95361372);
    //set zoom level  //4.4065,3.0519
    MKCoordinateSpan theSpan = MKCoordinateSpanMake(4.4065, 3.0519);
    MKCoordinateRegion theRegion = MKCoordinateRegionMake(theCenter, theSpan);
    
    //set scroll and zoom action
    _mapView.scrollEnabled = YES;
    _mapView.zoomEnabled = YES;
    
    //set map Region
    [_mapView setRegion:theRegion animated:NO];
    
    [self getNewMaskDataFromAPI];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [self checkLocationAuthorizationStatus];
}

- (void)annonationSettings{
    if(self.stockBackGroundColors.count == 0){
        self.stockBackGroundColors = [NSArray arrayWithObjects:
                            [UIColor grayColor],
                            [UIColor systemPinkColor],
                            [UIColor systemYellowColor],
                            [UIColor AnnotationGreen],
                            nil];
    }
    if(self.stockTextColors.count == 0){
        self.stockTextColors = [NSArray arrayWithObjects:
                            [UIColor whiteColor],
                            [UIColor whiteColor],
                            [UIColor blackColor],
                            [UIColor whiteColor],
                            nil];
    }
}

-(void)getNewMaskDataFromAPI{
    if(![self clearAllAnnonationsSuccess]){
        return;
    }
    [_actLoading startAnimating];
    btnRefresh.enabled = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [MaskDataAPI getMaskGataWithWriteDB:NO WithCompletion:^(BOOL success, NSArray<MaskData *> * _Nonnull array) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success){
                    [array enumerateObjectsUsingBlock:^(MaskData * _Nonnull maskdata, NSUInteger idx, BOOL * _Nonnull stop) {
                        AnnotationPharmacy *ann = [[AnnotationPharmacy alloc] initWithMaskData:maskdata];
                        [self.annonations addObject:ann];
                        if(maskdata.latitude <= 0 && maskdata.longitude <= 0){
                            [maskdata updateCoordinate:^(BOOL success, MaskData * _Nonnull maskdata, GeoDecodeFrom geodecodefrom) {
                                
                            }];
                        }
                    }];
                    [self->_actLoading stopAnimating];
                    self->btnRefresh.enabled = YES;
                    self->regionIsChanging = YES;
                    [self putAnnonationsOnMap];
                }
                else{
                    [self->_actLoading stopAnimating];
                    self->btnRefresh.enabled = NO;
                    [self showAlert:NSLocalizedString(@"ERROR", @"Error") message:@"抓取資料錯誤"];
                }
            });
        }];
    });
}

- (void)appReturnsActive{
    [self mapShowUserLocation:YES];
}

#pragma mark - Button Action
- (IBAction)gotoCurrentLocation:(id)sender{
    if(![_mapView showsUserLocation]){
        return;
    }
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusDenied || code == kCLAuthorizationStatusRestricted) {
        return;
    }
    
    CLLocationCoordinate2D currentCoor = [_mapView showsUserLocation] ? _mapView.userLocation.location.coordinate : CLLocationCoordinate2DMake(-1, -1);
    MKCoordinateSpan span = (_mapView.region.span.latitudeDelta >= 0.7f) ? MKCoordinateSpanMake(0.0300, 0.0207) : _mapView.region.span;
    MKCoordinateRegion currentRegion = MKCoordinateRegionMake(currentCoor, span);
    [_mapView setRegion:currentRegion animated:YES];
}

- (IBAction)refreshMaskDatas:(id)sender{
    [self getNewMaskDataFromAPI];
}

#pragma mark - 地圖 MapView Method
- (void)putAnnonationsOnMap{
        dispatch_async(self.MapQueue, ^{
            if(!self->regionIsChanging){ //地圖滑動時不做 self.annonations 歷遍
                return;
            }
            self->mapQueueIsBusy = YES; //在 elf.annonations 歷遍過程標示為  mapQueueIsBusy 狀態，於其他地方存取 self.annonations 內容時參考，避免 BAD_EXEC_ACCESS 情況，
            [self.annonations enumerateObjectsUsingBlock:^(AnnotationPharmacy * _Nonnull ann, NSUInteger idx, BOOL * _Nonnull stop) {
                //NSLog(@"--AnnotationPharmacy: %@",ann.maskdata.name);
                if([self Annotation:(id<MKAnnotation>)ann regionOfMap:self->_mapView]){
                    if(!ann.isOnMap){
                        if(self->currentAnnCount <= self->maxAnnCount){
                            ann.isOnMap = YES;
                            self->currentAnnCount++;
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self->_mapView addAnnotation:(id<MKAnnotation>)ann];
                            });
                            //NSLog(@"%@ %@-%@(%f,%f)[%@] addAnnotation",ann.maskdata.pharmacyid, ann.maskdata.name,ann.maskdata.addr,ann.maskdata.latitude,ann.maskdata.longitude,[self class].description);
                        }
                    }
                    else{
                    }
                }
                else{
                    if(ann.isOnMap){
                        ann.isOnMap = NO;
                        self->currentAnnCount--;
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self->_mapView removeAnnotation:(id<MKAnnotation>)ann];
                        });
                        //NSLog(@"removeAnnotation AnnotationPharmacy: %@",ann.maskdata.name);
                    }
                }
            }];
            self->mapQueueIsBusy = NO;
        });
}

- (BOOL)Annotation:(id <MKAnnotation> )annotation regionOfMap:(MKMapView *)mapView {
    if(MKMapRectContainsPoint([mapView visibleMapRect],MKMapPointForCoordinate(annotation.coordinate))){
        return YES;
    }
    else{
        return NO;
    }
}
#pragma mark - 地圖 @protocol MKMapViewDelegate <NSObject>
- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    if([annotation isKindOfClass:[MKUserLocation class]]) {
        [btnCurrentLocation setBackgroundImage:[UIImage imageNamed:@"BtnLocationOn"] forState:UIControlStateNormal];
        return nil;
    }

    MKMarkerAnnotationView *annview = (MKMarkerAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier];
    if (annview == nil) {
        annview = [[MKMarkerAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:MKMapViewDefaultAnnotationViewReuseIdentifier] ;
    }
    annview.canShowCallout=YES;
    annview.draggable = NO;
    AnnotationPharmacy *ann = annotation;
    annview.markerTintColor = [self.stockBackGroundColors objectAtIndex:ann.maskdata.stockstatus];
    annview.glyphTintColor = [self.stockTextColors objectAtIndex:ann.maskdata.stockstatus];
    //StockStatusIsOnlyChild
    NSInteger stockQty = (ann.maskdata.stockstatus == StockStatusIsOnlyChild) ? ann.maskdata.maskchild : ann.maskdata.maskadult;
    annview.glyphText = [NSString stringWithFormat:@"%li",(long)stockQty];
    return annview;
        
}

 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated{
     regionIsChanging = YES;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    regionIsChanging = NO;
}

- (void)mapViewDidChangeVisibleRegion:(MKMapView *)mapView API_AVAILABLE(ios(11), tvos(11), macos(10.13)){
    [self putAnnonationsOnMap];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0){
    if([view.annotation isKindOfClass:[MKUserLocation class]]) {
        [_mapView deselectAnnotation:view.annotation animated:NO];
        return ;
    }
    if([view isKindOfClass:[MKMarkerAnnotationView class]]){
        AnnotationPharmacy *ann = view.annotation;
        self.annonationCalloutView = [CallOutViewPharmacy viewtWithMaskData:ann.maskdata viewcontroller:self];
        [self.annonationCalloutView setStockColor:[self.stockBackGroundColors objectAtIndex:ann.maskdata.stockstatus]];
        [self.annonationCalloutView setStockTextColor:[self.stockTextColors objectAtIndex:ann.maskdata.stockstatus]];
        view.detailCalloutAccessoryView = self.annonationCalloutView;
    }
}
- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view NS_AVAILABLE(10_9, 4_0){
    self.annonationCalloutView = nil;
    view.detailCalloutAccessoryView = nil;
}

#pragma mark - App Method
- (void)mapShowUserLocation:(BOOL)toShow{
    if (!_mapView.showsUserLocation){
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            _mapView.showsUserLocation = toShow;
        }
        return;
    }
    _mapView.showsUserLocation = toShow;
}

- (void)showAlert:(NSString *)title message:(NSString *)msg{
    UIAlertController *alt = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"CLOSE", @"CLOSE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alt addAction:action];

    [self presentViewController:alt animated:YES completion:^{
        
    }];
}

- (BOOL)checkLocationAuthorizationStatus{ //檢查定位服務狀態
    NSUInteger code = [CLLocationManager authorizationStatus];
    if (code == kCLAuthorizationStatusDenied || code == kCLAuthorizationStatusRestricted) {
        //[self showAlert:NSLocalizedString(@"ERROR", @"錯誤") message:NSLocalizedString(@"Private Location", @"請開啟「隱私權」-「定位服務」")];
        UIAlertController *alt = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"ERROR", @"錯誤")
                                                                     message:NSLocalizedString(@"Private Location", @"請開啟「設定」-「隱私權」-「定位服務」")
                                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *act1 = [UIAlertAction actionWithTitle:NSLocalizedString(@"OPENSETTINGS", @"設定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
                                               options:@{} completionHandler:^(BOOL success) {
                [alt dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }];
        }];
        
        UIAlertAction *act2 = [UIAlertAction actionWithTitle:NSLocalizedString(@"CANCEL", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        
        [alt addAction:act1];
        [alt addAction:act2];
        
        [self presentViewController:alt animated:YES completion:^{
            
        }];
                                                                                               
        return NO;
    }
    
    if (code == kCLAuthorizationStatusNotDetermined ){ // && ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)] || [_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])) {
        // choose one request according to your business.
        CLLocationManager *_locationManager = [[CLLocationManager alloc] init];
        if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"]){
            if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]){
                [_locationManager requestAlwaysAuthorization];
            }
            [self mapShowUserLocation:YES];
            return [self checkLocationAuthorizationStatus];
        } else if([[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"]) {
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
                [_locationManager  requestWhenInUseAuthorization];
            }
            [self mapShowUserLocation:YES];
            return [self checkLocationAuthorizationStatus];
        } else {
            NSLog(@"Info.plist does not contain NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription");
            return NO;
        }
        return NO;
    }
    else if (code == kCLAuthorizationStatusAuthorizedWhenInUse )
    {
        [self mapShowUserLocation:YES];
        return YES;
    }
    else
    {
        return YES;
    }
}

- (BOOL)clearAllAnnonationsSuccess{
    if(mapQueueIsBusy){
        NSLog(@"MapQueueISBusy");
        return NO;
    }
    self.annonationCalloutView = nil;
    [_mapView removeAnnotations:(NSArray<id<MKAnnotation>> *)self.annonations];
    [self.annonations removeAllObjects];
    currentAnnCount = 0;
    return YES;
}
@end
