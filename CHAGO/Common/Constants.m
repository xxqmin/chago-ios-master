//
//  Contantss.m
//  CHAGO
//
//  Created by Do on 2020/04/04.
//  Copyright © 2020 Bizwizsystem. All rights reserved.
//

#import "Constants.h"

@implementation Constants

static NSDictionary *_paymentDict = nil;
+ (NSDictionary*)ABXRM_PAYMENT {
    if (_paymentDict == nil) {
        _paymentDict = @{
            @1:@"CreditCart",
            @2:@"BankTransfer",
            @3:@"MobilePayment",
            @4:@"ETC"
        };
    }
    return _paymentDict;
}

static NSDictionary *_sharingChannelDict = nil;
+ (NSDictionary*)ABXRM_SHARINGCHANNEL {
    if (_sharingChannelDict == nil) {
        _sharingChannelDict = @{
            @1:@"Facebook",
            @2:@"KakaoTalk",
            @3:@"KakaoStory",
            @4:@"Line",
            @5:@"WhatsApp",
            @6:@"QQ",
            @7:@"WeChat",
            @8:@"SMS",
            @9:@"Email",
            @10:@"CopyUrl",
            @11:@"ETC"
        };
    }
    return _sharingChannelDict;
}

static NSArray *_currencyArr = nil;
+ (NSArray*)ABXRM_CURRENCY {
    if (_currencyArr == nil) {
        _currencyArr = @[
            @"KRW",
            @"USD",
            @"JPY",
            @"EUR",
            @"GBP",
            @"CNY",
            @"TWD",
            @"HKD",
            @"IDR",
            @"INR",
            @"RUB",
            @"THB",
            @"VND",
            @"MYR"
        ];
    }
    return _currencyArr;
}

+ (NSString*)FUNC_search { return @"search"; }
+ (NSString*)FUNC_share { return @"share"; }
+ (NSString*)FUNC_addToWishList { return @"addToWishList"; }
+ (NSString*)FUNC_addToCart { return @"addToCart"; }
+ (NSString*)FUNC_viewList { return @"viewList"; }
+ (NSString*)FUNC_productView { return @"productView"; }
+ (NSString*)FUNC_purchase { return @"purchase"; }

+ (NSString*)DIC_keyword { return @"keyword"; }
+ (NSString*)DIC_sharingChannel { return @"sharingChannel"; }
+ (NSString*)DIC_orderId { return @"orderId"; }
+ (NSString*)DIC_productId { return @"productId"; }
+ (NSString*)DIC_productName { return @"productName"; }
+ (NSString*)DIC_unitPrice { return @"unitPrice"; }
+ (NSString*)DIC_quantity { return @"quantity"; }
+ (NSString*)DIC_currencyCode { return @"currencyCode"; }
+ (NSString*)DIC_category { return @"category"; }


@end
