//
//  Utils.m
//  CHAGO
//
//  Created by Do on 2020/04/04.
//  Copyright © 2020 Bizwizsystem. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+  (NSMutableDictionary *)getURLParmatersWithURL:(NSURL *)URL
{
    return [self getURLParmatersWithQuery:[URL query]];
}

+  (NSMutableDictionary *)getURLParmatersWithQuery:(NSString *)query
{
    NSMutableDictionary *parameters = nil;
    
    if (query.length > 0) {
        NSArray *components = [query componentsSeparatedByString:@"&"];
        parameters = [[NSMutableDictionary alloc] init];
        for (NSString *component in components)
        {
            NSArray *subcomponents = [component componentsSeparatedByString:@"="];
            if(subcomponents.count == 2)
            {
                
                [parameters setObject:[[subcomponents objectAtIndex:1] stringByRemovingPercentEncoding]
                               forKey:[[subcomponents objectAtIndex:0] stringByRemovingPercentEncoding]];
            }
            else
            {
                [parameters setObject:@"" forKey:[component stringByRemovingPercentEncoding]];
            }
        }
    }
    
    return parameters;
}

@end
