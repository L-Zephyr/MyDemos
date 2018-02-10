//
//  TracerouteRecord.m
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/8.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import "TracerouteRecord.h"

@implementation TracerouteRecord

- (NSString *)description {
    NSMutableString *record = [[NSMutableString alloc] initWithCapacity:20];
    [record appendFormat:@"%ld\t", (long)self.ttl];
    
    if (self.ip == nil) {
        [record appendFormat:@" \t"];
    } else {
        [record appendFormat:@"%@\t", self.ip];
    }
    
    for (int i = 0; i < self.total; ++i) {
        if (i < self.recvDurations.count) {
            [record appendFormat:@"%.2f ms\t", [self.recvDurations[i] floatValue] * 1000];
        } else {
            [record appendFormat:@"*\t"];
        }
    }
    
    return record;
}

@end
