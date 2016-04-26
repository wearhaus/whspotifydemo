//
//  NSArray+stringify.m
//  fest-app
//
//  Created by Ken Lauguico on 3/30/16.
//  Copyright © 2016 Ken Lauguico. All rights reserved.
//

#import "NSArray+stringify.h"

@implementation NSArray (stringify)

- (NSString *)stringify { return [self componentsJoinedByString:@""]; }

@end
