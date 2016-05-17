//
//  NSDictionary+QueryStringBuilder.m
//  wearhausios
//
//  Created by Ken Lauguico on 9/25/14.
//  Copyright (c) 2014 Wearhaus. All rights reserved.
//

#import "NSDictionary+QueryStringBuilder.h"

static NSString * escapeString(NSString *unencodedString)
{
    NSString *s = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                      (CFStringRef)unencodedString,
                                                                      NULL,
                                                                      (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                      kCFStringEncodingUTF8));
    return s;
}


@implementation NSDictionary (QueryStringBuilder)

- (NSString *)queryString
{
    NSMutableString *queryString = nil;
    NSArray *keys = [self allKeys];
    
    if ([keys count] > 0) 
    {
        for (id key in keys) 
        {
            id value = [self objectForKey:key];
            if (nil == queryString) 
            {
                queryString = [[NSMutableString alloc] init];
            }
            else
            {
                [queryString appendFormat:@"&"];
            }
            
            if (nil != key && [value isKindOfClass:[NSArray class]])
            {
                for (id arrayValue in value)
                {
                    [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(arrayValue)];
                    
                    if ([value indexOfObject:arrayValue] < [value count]-1)
                        [queryString appendFormat:@"&"];
                }
            }
            else if (nil != key && nil != value)
            {
                [queryString appendFormat:@"%@=%@", escapeString(key), escapeString(value)];
            }
            else if (nil != key) 
            {
                [queryString appendFormat:@"%@", escapeString(key)];
            }
        }
    }
    
    return queryString;
}

@end