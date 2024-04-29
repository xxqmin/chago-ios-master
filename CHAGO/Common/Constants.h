//
//  Contantss.h
//  CHAGO
//
//  Created by Do on 2020/04/04.
//  Copyright © 2020 Bizwizsystem. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Constants : NSObject

+ (NSDictionary*)ABXRM_PAYMENT;
+ (NSDictionary*)ABXRM_SHARINGCHANNEL;
+ (NSArray*)ABXRM_CURRENCY;

+ (NSString*)FUNC_search;
+ (NSString*)FUNC_share;
+ (NSString*)FUNC_addToWishList;
+ (NSString*)FUNC_addToCart;
+ (NSString*)FUNC_viewList;
+ (NSString*)FUNC_productView;
+ (NSString*)FUNC_purchase;

+ (NSString*)DIC_keyword;
+ (NSString*)DIC_sharingChannel;
+ (NSString*)DIC_orderId;
+ (NSString*)DIC_productId;
+ (NSString*)DIC_productName;
+ (NSString*)DIC_unitPrice;
+ (NSString*)DIC_quantity;
+ (NSString*)DIC_currencyCode;
+ (NSString*)DIC_category;

@end

NS_ASSUME_NONNULL_END
