//
//  NSDictionary+QueryStringBuilder.h
//  wearhausios
//
//  Created by Ken Lauguico on 9/25/14.
//  Copyright (c) 2014 Wearhaus. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSDictionary (QueryStringBuilder)

/**
 *  Builds a HTTP GET ready url query from an NSDictionary containing key-values
 *
 *  @return string containing a URL safe key-value string for appending to URL
 */
- (NSString *)queryString;

@end