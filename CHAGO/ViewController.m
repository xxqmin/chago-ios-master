//
//  ViewController.m
//  Chago
//
//  Created by JE on 2020/01/01.
//  Copyright © 2020 Bizwizsystem. All rights reserved.
//

#import "ViewController.h"
#import "SharedData.h"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AdSupport/AdSupport.h>
#import <AdBrixRmKit/AdBrixRmKit.h> // AdBrixRM V2 프레임워크
#import "Constants.h"
#import "Utils.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>

@import WebKit;
@import Firebase;
@import KakaoOpenSDK;

@interface ViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler,CLLocationManagerDelegate>

@property (strong,nonatomic)IBOutlet UIView *containerView;
@property (strong,nonatomic)WKWebView *wv;
// 지역 변수를 선언합니다.
// 웹뷰의 랜더 속도 및 각종 설정들을 담당하는 클래스입니다.
@property (strong,nonatomic)WKWebViewConfiguration *config;
// 자바스크립트에서 메시지를 받거나 자바스크립트를 실행하는데 필요한 클래스입니다.
@property (strong,nonatomic)WKUserContentController *jsctrl;
@property (strong,nonatomic)CLLocationManager *locationManager;

@end

@implementation ViewController



//ios 15 대응. 추가된 코드
-(void)applicationDidBecomeActive:(BOOL)animated{
    AdBrixRM *adBrix = [AdBrixRM sharedInstance];
    
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                [adBrix startGettingIDFA];
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                [adBrix stopGettingIDFA];
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                [adBrix stopGettingIDFA];
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                [adBrix stopGettingIDFA];
                    break;
                default:
                [adBrix stopGettingIDFA];
                    break;
            }
        }];
    }
}

//ios 15 대응. 추가된 코드
-(void)viewDidAppear:(BOOL)animated{
    AdBrixRM *adBrix = [AdBrixRM sharedInstance];
    
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            switch (status) {
                case ATTrackingManagerAuthorizationStatusAuthorized:
                [adBrix startGettingIDFA];
                    break;
                case ATTrackingManagerAuthorizationStatusDenied:
                [adBrix stopGettingIDFA];
                    break;
                case ATTrackingManagerAuthorizationStatusRestricted:
                [adBrix stopGettingIDFA];
                    break;
                case ATTrackingManagerAuthorizationStatusNotDetermined:
                [adBrix stopGettingIDFA];
                    break;
                default:
                [adBrix stopGettingIDFA];
                    break;
            }
        }];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //NSLog(@"=========viewDidLoad======");
    CGRect rect = self.containerView.frame;
    rect.origin.y = 0;
    self.wv.frame = rect;
    self.config = [[WKWebViewConfiguration alloc] init];
    self.jsctrl = [[WKUserContentController alloc] init];
    
    // 자바스크립트 -> ios에 사용될 핸들러 이름을 추가해줍니다.
    [self.jsctrl addScriptMessageHandler:self name:@"callbackHandler"];
    // WkWebView의 configuration에 스크립트에 대한 설정을 정해줍니다.
    [self.config setUserContentController:_jsctrl];
    
    self.wv = [[WKWebView alloc] initWithFrame:rect configuration:self.config];
    self.wv.UIDelegate = self;
    self.wv.navigationDelegate = self;
    
    [self.containerView addSubview:self.wv];
    
    [self initLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePushNotification:)
                                                 name:@"pushNotification"
                                               object:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}
-(void)initLoad{
    [self.wv evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error)
     
     {
        NSDictionary *pushinfo = [SharedData dataTelkitForType:eDataTypePushInfo];
        
        self.wv.customUserAgent = [NSString stringWithFormat:@"%@ CHAGO_IOS",result];
        NSString *link = @"";
        if(pushinfo!=nil && [pushinfo count]>0){
            link = [NSString stringWithFormat:@"link=%@",[pushinfo objectForKey:@"link"]];
        }
        NSURL *url =[NSURL URLWithString:@"https://cha-go.com/"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        //NSLog(@"url:%@",url);
        [self.wv loadRequest:request];
    }];
}

-(void)didReceivePushNotification:(NSNotification*)nc{
    //NSLog(@"didReceivePushNotification");
    [SharedData setTelkitData:nc.userInfo forType:eDataTypePushInfo];
    NSDictionary *aps   = [nc.userInfo objectForKey:@"aps"];
    NSDictionary *alert = [aps objectForKey:@"alert"];
    NSString *body = [alert objectForKey:@"body"];
    NSString *title = [alert objectForKey:@"title"];
    [self pushAlert:title body:body];
}


-(void)pushAlert:(NSString*)title body:(NSString*)body{
    //Step 1: Create a UIAlertController
    UIAlertController *myAlertController = [UIAlertController alertControllerWithTitle:title
                                                                               message:body
                                                                        preferredStyle:UIAlertControllerStyleAlert                   ];
    
    //Step 2: Create a UIAlertAction that can be added to the alert
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"확인"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
        //Do some thing here, eg dismiss the alertwindow
        [self initLoad];
        
        [myAlertController dismissViewControllerAnimated:YES completion:nil];
        
    }];
    
    //Step 3: Add the UIAlertAction ok that we just created to our AlertController
    [myAlertController addAction: ok];
    
    //Step 4: Present the alert to the user
    
    [self presentViewController:myAlertController animated:YES completion:nil];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        completionHandler(true);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        completionHandler(false);
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil
                                                                             message:prompt
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = defaultText;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        NSString *t = alertController.textFields.firstObject.text;
        if(t!=nil && [t length]>0){
            completionHandler(t);
        } else {
            completionHandler(defaultText);
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    //NSLog(@"1. didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    //NSLog(@"2. didFinishNavigation");
    CGRect rect = self.containerView.frame;
    rect.origin.y = 0;
    webView.frame = rect;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    //NSLog(@"3. didFailNavigation");
}

- (BOOL)webView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    //NSLog(@"url:%@",[request URL]);
    return YES;
}

-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURLRequest *request = navigationAction.request;
    //NSLog(@"url=%@",request.URL);
    [webView evaluateJavaScript:@"navigator.userAgent" completionHandler:^(id _Nullable result, NSError * _Nullable error)
     {
        //NSLog(@"customUserAgent:%@",webView.customUserAgent);
        //NSLog(@"result:%@",result);
    }];
    
    //현재 URL을 읽음
    NSString *URLString = [NSString stringWithString:[request.URL absoluteString]];
    
    //app store URL 여부 확인
    BOOL goAppStore1 = ([URLString rangeOfString:@"phobos.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    BOOL goAppStore2 = ([URLString rangeOfString:@"itunes.apple.com" options:NSCaseInsensitiveSearch].location != NSNotFound);
    
    //app store 로 연결하는 경우 앱스토어 APP을 열어 준다. (isp, bank app 이 설치하고자 경우)
    if( goAppStore1 || goAppStore2 ) {
        if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
            [[UIApplication sharedApplication] openURL:request.URL options:@{}
                                     completionHandler:^(BOOL success) {
            }];
        } else {
            BOOL success = [[UIApplication sharedApplication] openURL:request.URL];
        }
        
        //[[UIApplication sharedApplication] openURL:request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    NSString *scheme = request.URL.scheme;
    NSString *host = request.URL.host;
    NSString *query = request.URL.query;
    /*
     NSLog(@"scheme=%@",scheme);
     NSLog(@"host=%@",host);
     NSLog(@"query=%@",query);
     */
    
    NSMutableDictionary *dic = [Utils getURLParmatersWithURL:request.URL];
    
    BOOL isAdbrixContains = FALSE;
    
    if ([scheme isEqualToString:@"adbrix"]) {
        NSLog(@"adbix invoked !!");
        
        if ([host isEqualToString:@"signUp"]) {
            [self adbrixSignup:dic];
        } else if ([host isEqualToString:@"login"]) {
            [self adbrixLogin:query];
        } else if ([host isEqualToString:@"logout"]) {
            [self adbrixLogout];
        } else if ([host isEqualToString:@"event"]) {
            NSRange tokenizePosition = [query rangeOfString:@"&"];
            if (tokenizePosition.location != NSNotFound){
                NSString *eventName = [query substringToIndex:tokenizePosition.location];
                NSDictionary *params = [Utils getURLParmatersWithQuery:[query substringFromIndex:NSMaxRange(tokenizePosition)]];
                [self adbrixEvent:eventName params:params];
            }
        }
        else if ([host containsString:[Constants FUNC_purchase]] ||
                 [host containsString:[Constants FUNC_viewList]] ||
                 [host containsString:[Constants FUNC_addToWishList]] ||
                 [host containsString:[Constants FUNC_share]] ||
                 [host containsString:[Constants FUNC_search]] ||
                 [host containsString:[Constants FUNC_productView]] ||
                 [host containsString:[Constants FUNC_addToCart]]) {
            
            isAdbrixContains = TRUE;
            
            NSMutableArray *cateArr = [NSMutableArray new];
            
            NSString *cate = [dic valueForKey:[Constants DIC_category]];
            if (cate != nil) {
                NSArray *categories = [cate componentsSeparatedByString:@"."];
                for (NSString *str in categories) {
                    if (cateArr.count >= 5) break;
                    [cateArr addObject:str];
                }
            } else {
                if (cateArr.count < 5) {
                    [cateArr addObject:@""];
                }
            }
            
            NSString *productId = [dic valueForKey:[Constants DIC_productId]];
            NSString *productName = [dic valueForKey:[Constants DIC_productName]];
            NSString *priceNum = [dic valueForKey:[Constants DIC_unitPrice]];
            NSString *quantityNum = [dic valueForKey:[Constants DIC_quantity]];
            NSString *currencyString = [dic valueForKey:[Constants DIC_currencyCode]];
            
            if (productId != nil && productName != nil && priceNum != nil && quantityNum != nil && currencyString != nil) {
                
                NSMutableArray *arr = [NSMutableArray new];
                
                AdBrixRM *adbrixRM = [AdBrixRM sharedInstance];
                
                // AdBrixRmCommerceProductCategoryModel * cateModel = [adbrixRM createCommerceProductCategoryDataByStringsWithCategoryArray:cateArr];
                
                // AdBrixRmCommerceProductModel * productModel = [adbrixRM createCommerceProductDataWithAttrWithProductId:productId
                                                                                                           //productName:productName
                                                                                                                 //price:(double)priceNum.intValue
                                                                                                              //quantity:quantityNum.intValue
                                                                                                              //discount:0
                                                                                                        //currencyString:[self validCurrencyWithCode:currencyString]
                                                                                                              //category:cateModel
                                                                                                       //productAttrsMap:nil];
                
               // [arr addObject:productModel];
                
                if ([host containsString:[Constants FUNC_purchase]]) {
                    NSString *orderId = [dic valueForKey:[Constants DIC_orderId]];
                    if (orderId != nil) {
                        NSString *code = [[Constants ABXRM_PAYMENT] valueForKey:@"1"];
                        if (code != nil) {
                            code = @"CreditCard";
                        }
                        
                        //[adbrixRM commonPurchaseWithOrderId:orderId
                                                //productInfo:arr
                                                   //discount:0
                                             //deliveryCharge:0
                                              //paymentMethod:[adbrixRM convertPayment:[self validPaymentWithCode:code]]];
                    }
                    
                } else if ([host containsString:[Constants FUNC_productView]]) {
                    
                    //[adbrixRM commerceProductViewWithProductInfo:productModel];
                    
                } else if ([host containsString:[Constants FUNC_viewList]]) {
                    
                    [adbrixRM commerceListViewWithProductInfo:arr];
                    
                } else if ([host containsString:[Constants FUNC_addToCart]]) {
                    
                    [adbrixRM commerceAddToCartWithProductInfo:arr];
                    
                } else if ([host containsString:[Constants FUNC_addToWishList]]) {
                    
                    [adbrixRM commerceAddToWishListWithProductInfo:arr[0]];
                    
                } else if ([host containsString:[Constants FUNC_share]]) {
                    
                    NSString *shareName = [dic valueForKey:[Constants DIC_sharingChannel]];
                    if (shareName != nil) {
                        [adbrixRM commerceShareWithChannel:[adbrixRM convertChannel:[self validSharingChannelWithCode:shareName]] productInfo:arr[0]];
                    }
                    
                } else if ([host containsString:[Constants FUNC_search]]) {
                    
                    NSString *keyword = [dic valueForKey:[Constants DIC_keyword]];
                    if (keyword != nil) {
                        [adbrixRM commerceSearchWithProductInfo:arr keyword:keyword];
                    }
                    
                }
            }
        }
        
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
        
    } else {
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSArray *queryArr = [query componentsSeparatedByString:@"&"];
        if(queryArr!=nil && [queryArr count]>0){
            for(NSString *str in queryArr){
                NSArray *values = [str componentsSeparatedByString:@"="];
                if([values count]>=2){
                    [params setObject:values[1] forKey:values[0]];
                } else {
                    [params setObject:@"" forKey:values[0]];
                }
            }
        }
        if(![request.URL.absoluteString hasPrefix:@"http://"] && ![request.URL.absoluteString hasPrefix:@"https://"]) {
            if([[UIApplication sharedApplication] canOpenURL:request.URL]) {
                if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
                    [[UIApplication sharedApplication] openURL:request.URL options:@{}
                                             completionHandler:^(BOOL success) {
                        //NSLog(@"Open %@: %d",scheme,success);
                    }];
                } else {
                    BOOL success = [[UIApplication sharedApplication] openURL:request.URL];
                    //NSLog(@"Open %@: %d",scheme,success);
                }
                decisionHandler(WKNavigationActionPolicyCancel);
                return;
            }
        }
    }
    
    decisionHandler(isAdbrixContains ? WKNavigationActionPolicyCancel : WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message
{
    //NSLog(@"message.body:%@",message.body);
    
    if([message.body isEqualToString:@"startLocation"]){
        [self startGpsLocation];
    } else if([message.body isEqualToString:@"stopLocation"]){
        [self stopGpsLocation];
    } else if([message.body isEqualToString:@"fcmToken"]){
        NSString *token = [FIRMessaging messaging].FCMToken;
        
        NSString *callJavascript = [NSString stringWithFormat:@"ios_token('%@');",token];
        
        [self.wv evaluateJavaScript:callJavascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            
        }];
    } else if([message.body isEqualToString:@"connectKakao"]){
        KOSession *session = [KOSession sharedSession];
        
        if (session.isOpen) {
            [session close];
        }
        
        //session.presentingViewController = self.navigationController;
        [session openWithCompletionHandler:^(NSError * _Nullable error) {
            //NSLog(@"error:%@",error);
            session.presentingViewController = nil;
            if (session.isOpen)
            {
                [KOSessionTask userMeTaskWithCompletion:^(NSError * _Nullable error, KOUserMe * _Nullable result) {
                    //NSLog(@"error:%@",error);
                    if (result)
                    {
                        NSString* snsId=result.ID;
                        NSString* nickname=result.account.profile.nickname;
                        NSString* profileImageURL= result.account.profile.profileImageURL.absoluteString;
                        NSString* thumbnailImageURL=result.account.profile.thumbnailImageURL.absoluteString;
                        
                        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:snsId,@"id",nickname,@"name",profileImageURL,@"profileImagePath",thumbnailImageURL,@"thumbnailImagePath"
                                             , nil];
                        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
                        NSString* jsonDataStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                        //NSLog(@"%@",jsonDataStr);
                        NSString *callJavascript = [NSString stringWithFormat:@"resultAppKakao(JSON.stringify(%@))",jsonDataStr];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.wv evaluateJavaScript:callJavascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                                //NSLog(@"error:%@",error);
                            }];
                        });
                    }
                }];
            }
        } authType:KOAuthTypeTalk];
    } else if([message.body isEqualToString:@"disConnectKakao"]){
        KOSession *session = [KOSession sharedSession];
        if (session.isOpen) {
            [session logoutAndCloseWithCompletionHandler:^(BOOL success, NSError * _Nullable error) {
                
            }];
        }
    }
}

- (void)stopGpsLocation{
    [self.locationManager stopUpdatingLocation];
}
- (void)startGpsLocation {
    //NSLog(@"startStandardUpdates");
    
    // Create the location manager if this object does not
    // already have one.
    if (nil == self.locationManager){
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = 1; // meters
    [self.locationManager requestWhenInUseAuthorization];
    
    [self.locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //NSLog(@"locationManager didUpdateLocations");
    
    //label1.text = @"위치 변경";
    
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    double lat = location.coordinate.latitude;
    double lng = location.coordinate.longitude;
    
    NSString *callJavascript = [NSString stringWithFormat:@"update_gps('%f','%f');",lat,lng];
    
    [self.wv evaluateJavaScript:callJavascript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
}

//------------------------------------------------------------------------------
// About Adbrix
//------------------------------------------------------------------------------
- (void)adbrixSignup:(NSDictionary*)params {
    AdBrixRM *adbrixRM = [AdBrixRM sharedInstance];
    AdBrixRmAttrModel *commonAttr = [AdBrixRmAttrModel new];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [commonAttr setAttrDataString:key :obj];
    }];
    
    [adbrixRM commonSignUpWithAttrWithChannel:AdBrixRmSignUpChannelAdBrixRmSignUpUserIdChannel commonAttr:commonAttr];
}

- (void)adbrixLogin:(NSString*)userId {
    AdBrixRM *adbrixRM = [AdBrixRM sharedInstance];
    [adbrixRM loginWithUserId:userId];
}

- (void)adbrixLogout {
    AdBrixRM *adbrixRM = [AdBrixRM sharedInstance];
    [adbrixRM logout];
}

- (void)adbrixEvent:(NSString*)eventName params:(NSDictionary*)params {
    AdBrixRM *adbrixRM = [AdBrixRM sharedInstance];
    AdBrixRmAttrModel *eventAttr = [AdBrixRmAttrModel new];
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [eventAttr setAttrDataString:key :obj];
    }];
    
    [adbrixRM eventWithAttrWithEventName:eventName value:eventAttr];
}

- (NSString*)validCurrencyWithCode:(NSString*)code {
    NSString *type = @"KRW";
    
    for (NSString *v in [Constants ABXRM_CURRENCY]) {
        if ([v isEqualToString:code]) {
            type = v;
            break;
        }
    }
    return type;
}

- (NSInteger)validPaymentWithCode:(NSString*)code {
    __block NSInteger type = 1;
    
    [[Constants ABXRM_PAYMENT] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([(NSString*)obj isEqualToString:code]) {
            type = [key intValue];
            *stop = YES;
        }
    }];
    
    return type;
}

- (NSInteger)validSharingChannelWithCode:(NSString*)code {
    __block NSInteger type = 1;
    
    [[Constants ABXRM_SHARINGCHANNEL] enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([(NSString*)obj isEqualToString:code]) {
            type = [key intValue];
            *stop = YES;
        }
    }];
    
    return type;
}

@end
