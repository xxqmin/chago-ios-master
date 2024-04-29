//
//  AppDelegate.m
//  Chago
//
//  Created by JE on 2020/01/01.
//  Copyright © 2020 Bizwizsystem. All rights reserved.
//

#import "AppDelegate.h"

#import <Firebase.h>
#import <FirebaseCore/FirebaseCore.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import "SharedData.h"
#import "IgaworksCore/IgaworksCore.h"
#import <AdSupport/AdSupport.h>
#import <AdBrixRmKit/AdBrixRmKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>



@import Firebase;
@import UserNotifications;
@import KakaoOpenSDK;

NSString *const kGCMMessageIDKey = @"gcm.message_id";

@interface AppDelegate ()<FIRMessagingDelegate,UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    AdBrixRM *adBrix = [AdBrixRM sharedInstance];
    
    
    //추가된 코드
    
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
    
    [FIRApp configure];
    [FIRMessaging messaging].delegate = self;
    [FIRMessaging messaging].autoInitEnabled = YES;
    [[NSNotificationCenter defaultCenter] addObserverForName:FIRMessagingRegistrationTokenRefreshedNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        // 토큰 갱신 처리
        NSString *refreshedToken = [FIRMessaging messaging].FCMToken;
        NSLog(@"Remote FCM token: %@", refreshedToken);
    }];
    
   
    
    //1) 애플 광고 식별자 설정
    if (NSClassFromString(@"ASIdentifierManager")){
        NSUUID *ifa =[[ASIdentifierManager sharedManager]advertisingIdentifier];
        
        //2024.04.29 L2K Modified.
        // [adBrix setAppleAdvertisingIdentifier:[ifa UUIDString]];
    }

    //2) 로그 레벨 설정
    
    // 2024.04.29 L2K Modified.
    // [adBrix setLogLevel:AdBrixLogLevelTRACE];

    //3) 이벤트 업로드 주기 설정 : 개수 / 시간
    [adBrix setEventUploadCountInterval:AdBrixEventUploadCountIntervalMIN];
    [adBrix setEventUploadTimeInterval:AdBrixEventUploadTimeIntervalMAX];
    
    //4) 앱키 설정
    [adBrix initAdBrixWithAppKey:@"beV36ujZK0mAQtxdR2AgNw" secretKey:@"7EefITgZaUK7CgLz7d0uVw"];
    
    if (@available(iOS 10.0, *)) {
        if ([UNUserNotificationCenter class] != nil) {
            // iOS 10 or later
            // For iOS 10 display notification (sent via APNS)
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            UNAuthorizationOptions authOptions = UNAuthorizationOptionAlert |
            UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
            [[UNUserNotificationCenter currentNotificationCenter]
             requestAuthorizationWithOptions:authOptions
             completionHandler:^(BOOL granted, NSError * _Nullable error) {
                 // ...
             }];
        }
    }else {
        // iOS 10 notifications aren't available; fall back to iOS 8-9 notifications.
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    [application registerForRemoteNotifications];
    
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    
    if(launchOptions!=nil){
        NSDictionary *pushDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        [SharedData setTelkitData:pushDic forType:eDataTypePushInfo];
        /*
        NSData* kData = [NSJSONSerialization dataWithJSONObject:pushDic options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString* kJson = [[NSString alloc] initWithData:kData encoding:NSUTF8StringEncoding];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"telkit"
                                                        message:kJson
                                                       delegate:self
                                              cancelButtonTitle:nil otherButtonTitles:nil,nil];
        
        [alert show];
         */
    }
    
    return YES;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_9_0

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([KOSession isKakaoAccountLoginCallback:url])
    {
        return [KOSession handleOpenURL:url];
    }
    else if ([url.scheme isEqualToString:@"chago"] && [url.host isEqualToString:@"main"])
    {
        // pass open url for commerce conversion
        AdBrixRM *adBrix = [AdBrixRM sharedInstance]; //또는 AdBrix *adBrixs = AdBrixRM.sharedInstance;
        [adBrix deepLinkOpen:url];
        return YES;
    }
    
    return NO;
}

#else

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary *)options
{
    if ([KOSession isKakaoAccountLoginCallback:url])
    {
        return [KOSession handleOpenURL:url];
    }
    else if ([url.scheme isEqualToString:@"chago"] && [url.host isEqualToString:@"main"])
    {
        // pass open url for commerce conversion
        AdBrixRM *adBrix = [AdBrixRM sharedInstance];
        [adBrix deepLinkOpenWithUrl:url];
        
        // 2024.04.29 L2K Modified.
        // [adBrix deepLinkOpenWithUrl:url eventDateStr:[self getDateStr]];
        return YES;
    }
    
    return NO;
    
}
#endif

- (NSString *)getDateStr
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];
    
    return dateString;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}
/*
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([KOSession isKakaoAccountLoginCallback:url])
    {
        return [KOSession handleOpenURL:url];
    }
    
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([KOSession isKakaoAccountLoginCallback:url])
    {
        return [KOSession handleOpenURL:url];
    }
    
    return NO;
}
*/
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [KOSession handleDidEnterBackground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [KOSession handleDidBecomeActive];
    
    
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

    
    
    [FBSDKAppEvents activateApp];
}






- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



// [START receive_message]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    //NSLog(@"%@", userInfo);
    [SharedData setTelkitData:userInfo forType:eDataTypePushInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification"
                                                        object:nil
                                                      userInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    //NSLog(@"%@", userInfo);
    [SharedData setTelkitData:userInfo forType:eDataTypePushInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification"
                                                        object:nil
                                                      userInfo:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
// [END receive_message]

// [START ios_10_message_handling]
// Receive displayed notifications for iOS 10 devices.
// Handle incoming notification messages while app is in the foreground.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = notification.request.content.userInfo;
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // [[FIRMessaging messaging] appDidReceiveMessage:userInfo];
    
    // Print message ID.
    if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    //NSLog(@"%@", userInfo);
    [SharedData setTelkitData:userInfo forType:eDataTypePushInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification"
                                                        object:nil
                                                      userInfo:userInfo];
    // Change this to your preferred presentation option
    completionHandler(UNNotificationPresentationOptionNone);
}

// Handle notification messages after display notification is tapped by the user.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void(^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (userInfo[kGCMMessageIDKey]) {
        //NSLog(@"Message ID: %@", userInfo[kGCMMessageIDKey]);
    }
    
    // Print full message.
    //NSLog(@"%@", userInfo);
    [SharedData setTelkitData:userInfo forType:eDataTypePushInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification"
                                                        object:nil
                                                      userInfo:userInfo];
    completionHandler();
}

// [END ios_10_message_handling]

// [START refresh_token]
- (void)messaging:(FIRMessaging *)messaging didReceiveRegistrationToken:(NSString *)fcmToken {
    //NSLog(@"FCM registration token: %@", fcmToken);
    // Notify about received token.
    NSDictionary *dataDict = [NSDictionary dictionaryWithObject:fcmToken forKey:@"token"];
    [[NSNotificationCenter defaultCenter] postNotificationName:
     @"FCMToken" object:nil userInfo:dataDict];
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new token is generated.
}
// [END refresh_token]

// [START ios_10_data_message]
// Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
// To enable direct data messages, you can set [Messaging messaging].shouldEstablishDirectChannel to YES.

/*
- (void)messaging:(FIRMessaging *)messaging didReceiveMessage:(FIRMessagingRemoteMessage *)remoteMessage {
    //NSLog(@"Received data message: %@", remoteMessage.appData);
}*/
// [END ios_10_data_message]

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //NSLog(@"Unable to register for remote notifications: %@", error);
}

// This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
// If swizzling is disabled then this function must be implemented so that the APNs device token can be paired to
// the FCM registration token.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    //NSLog(@"APNs device token retrieved: %@", deviceToken);
    
    // With swizzling disabled you must set the APNs device token here.
    [FIRMessaging messaging].APNSToken = deviceToken;
}


@end
