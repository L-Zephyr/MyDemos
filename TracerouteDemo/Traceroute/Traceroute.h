//
//  Traceroute.h
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/8.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TracerouteRecord.h"

typedef void (^TracerouteStepCallback)(TracerouteRecord *record);
typedef void (^TracerouteFinishCallback)(NSArray<TracerouteRecord *> *results, BOOL succeed);

@interface Traceroute : NSObject

/**
 开始对指定的IP进行traceroute诊断，在当前线程同步执行
 
 @param host         诊断的域名或IP地址
 @param stepCallback 每一跳的结果回调
 @param finish       Traceroute结束的回调
 */
+ (instancetype)startTracerouteWithHost:(NSString *)host
                           stepCallback:(TracerouteStepCallback)stepCallback
                                 finish:(TracerouteFinishCallback)finish;

@end
