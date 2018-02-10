//
//  TracerouteRecord.h
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/8.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TracerouteRecord : NSObject

@property (nonatomic) BOOL success;
@property (nonatomic) NSString *ip;
@property (nonatomic) NSArray<NSNumber *> *recvDurations; // 每次的往返耗时
@property (nonatomic) NSInteger total; // 次数
@property (nonatomic) NSInteger ttl; // 当前的TTL

@end
