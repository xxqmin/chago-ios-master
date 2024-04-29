//
//  Utils.h
//  CHAGO
//
//  Created by Do on 2020/04/04.
//  Copyright © 2020 Bizwizsystem. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject
+ (NSMutableDictionary *)getURLParmatersWithURL:(NSURL *)URL;
+ (NSMutableDictionary *)getURLParmatersWithQuery:(NSString *)query;
@end

NS_ASSUME_NONNULL_END
