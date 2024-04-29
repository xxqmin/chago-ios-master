//
//  SharedData.m
//  Telkit
//
//  Created by JE on 25/08/2019.
//  Copyright © 2019 Bizwizsystem. All rights reserved.
//

#import "SharedData.h"

@implementation SharedData

+ (void)setTelkitData:(id)data forType:(eDataType)type
{
    NSString *key = [NSString stringWithFormat:@"DataTelkitKey%zd", type];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (id)dataTelkitForType:(eDataType)type
{
    NSString *key = [NSString stringWithFormat:@"DataTelkitKey%zd", type];
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

@end
