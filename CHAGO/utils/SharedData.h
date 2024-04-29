//
//  SharedData.h
//  Telkit
//
//  Created by JE on 25/08/2019.
//  Copyright © 2019 Bizwizsystem. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, eDataType) {
    eDataTypeUserInfo = 1,
    eDataTypePushInfo = 2,
};

@interface SharedData : NSObject

+ (void)setTelkitData:(id)data forType:(eDataType)type;
+ (id)dataTelkitForType:(eDataType)type;

@end

NS_ASSUME_NONNULL_END
