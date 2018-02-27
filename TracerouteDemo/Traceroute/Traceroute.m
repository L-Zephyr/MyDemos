//
//  Traceroute.m
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/8.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import "Traceroute.h"
#import "TracerouteCommon.h"

#define kTraceStepMaxAttempts 3 // 每一跳尝试的次数
#define kTraceRouteFailOvertime 10 // 连续失败指定次数直接结束
#define kTraceRoutePort 20000 // traceroute所用的端口号
#define kTraceMaxJump 30 // 最多尝试30跳

@interface Traceroute()

@property (nonatomic) NSString *ipAddress; // 待诊断的IP地址
@property (nonatomic) NSString *hostname;
@property (nonatomic) NSInteger maxTtl; // 最大跳数
@property (nonatomic) NSMutableArray<TracerouteRecord *>* results;
@property (nonatomic) NSInteger failOvertime; // 连续失败的次数

@property (nonatomic) TracerouteStepCallback stepCallback;
@property (nonatomic) TracerouteFinishCallback finishCallback;

@end

@implementation Traceroute

+ (instancetype)startTracerouteWithHost:(NSString *)host
                           stepCallback:(TracerouteStepCallback)stepCallback
                                 finish:(TracerouteFinishCallback)finish {
    Traceroute *traceroute = [[Traceroute alloc] initWithHost:host maxTtl:kTraceMaxJump stepCallback:stepCallback finish:finish];
    [traceroute run];
    return traceroute;
}

- (instancetype)initWithHost:(NSString*)host
                      maxTtl:(NSInteger)maxTtl
                stepCallback:(TracerouteStepCallback)stepCallback
                      finish:(TracerouteFinishCallback)finish {
    if (self = [super init]) {
        _hostname = host;
        _maxTtl = maxTtl;
        _stepCallback = stepCallback;
        _finishCallback = finish;
        _results = [[NSMutableArray alloc] init];
        _failOvertime = 0;
    }
    return self;
}

#pragma mark - Private

- (void)run {
    NSArray *addresses = [TracerouteCommon resolveHost:_hostname];
    if (addresses.count == 0) {
        NSLog(@"DNS解析失败");
        return;
    }
    _ipAddress = [addresses firstObject];
//    _ipAddress = @"2400:da00::dbf:0:100"; // test
    // 作为Demo，域名有多个地址时只取第一个
    if (addresses.count > 0) {
        NSLog(@"%@ has multiple addresses, using %@", _hostname, _ipAddress);
    }
    
    BOOL isIPv6 = [_ipAddress rangeOfString:@":"].location != NSNotFound;
    // 目标主机地址
    struct sockaddr *remoteAddr = [TracerouteCommon makeSockaddrWithAddress:_ipAddress
                                                                       port:(int)kTraceRoutePort
                                                                     isIPv6:isIPv6];
    
    
    if (remoteAddr == NULL) {
        return;
    }
    
    // 创建套接字
    int send_sock;
    if ((send_sock = socket(remoteAddr->sa_family,
                            SOCK_DGRAM,
                            isIPv6 ? IPPROTO_ICMPV6 : IPPROTO_ICMP)) < 0) {
        NSLog(@"创建socket失败");
        return;
    }
    
    // 超时时间3秒
    struct timeval timeout;
    timeout.tv_sec = 3;
    timeout.tv_usec = 0;
    setsockopt(send_sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(timeout));
    
    int ttl = 1;
    BOOL succeed = NO;
    do {
        if (_failOvertime == kTraceRouteFailOvertime) { // 连续失败最大次数
            break;
        }
        
        // 设置数据包TTL，依次递增
        if (setsockopt(send_sock, isIPv6 ? IPPROTO_IPV6 : IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0) {
            NSLog(@"setsockopt失败");
        }
        succeed = [self sendAndRecv:send_sock addr:remoteAddr ttl:ttl];
    } while (++ttl <= _maxTtl && !succeed);
    
    close(send_sock);
    
    // traceroute结束，回调结果
    if (_finishCallback) {
        _finishCallback([_results copy], succeed);
    }
}

/**
 向指定目标连续发送3个数据包

 @param sendSock 发送用的socket
 @param addr     地址
 @param ttl      TTL大小
 @return 如果找到目标服务器则返回YES，否则返回NO
 */
- (BOOL)sendAndRecv:(int)sendSock
               addr:(struct sockaddr *)addr
                ttl:(int)ttl {
    char buff[200];
    BOOL finished = NO;
    BOOL isIPv6 = [_ipAddress rangeOfString:@":"].location != NSNotFound;
    
    // 构建icmp报文
    uint16_t identifier = (uint16_t)ttl;
    NSData *payload = [[NSString stringWithFormat:@"traceroute icmp packet %d", ttl] dataUsingEncoding:NSASCIIStringEncoding];
    NSData *packetData = [TracerouteCommon makeICMPPacketWithID:identifier
                                                       sequence:ttl
                                                        payload:payload
                                                       isICMPv6:isIPv6];
    
    // 记录结果
    TracerouteRecord *record = [[TracerouteRecord alloc] init];
    record.ttl = ttl;
//    record.total = kTraceStepMaxAttempts;
    
    BOOL receiveReply = NO;
    NSMutableArray *durations = [[NSMutableArray alloc] init];
    
    // 连续发送3个ICMP报文，记录往返时长
    for (int try = 0; try < kTraceStepMaxAttempts; try ++) {
        NSDate* startTime = [NSDate date];
        // 发送icmp报文
        ssize_t sent = sendto(sendSock, packetData.bytes, packetData.length, 0, (struct sockaddr*)addr, sizeof(struct sockaddr));
        if (sent < 0) {
            continue;
        }
        
        // 接收icmp数据
        struct sockaddr remoteAddr;
        socklen_t len = sizeof(remoteAddr);
        ssize_t resultLen = recvfrom(sendSock, buff, sizeof(buff), 0, (struct sockaddr*)&remoteAddr, &len);
        if (resultLen < 0) {
            // fail
            [durations addObject:[NSNull null]];
            continue;
        } else {
            receiveReply = YES;
            NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
            
            // 解析IP地址
            NSString* remoteAddress = nil;
            if (!isIPv6) {
                char ip[INET_ADDRSTRLEN] = {0};
                inet_ntop(AF_INET, &((struct sockaddr_in *)&remoteAddr)->sin_addr.s_addr, ip, sizeof(ip));
                remoteAddress = [NSString stringWithUTF8String:ip];
            } else {
                char ip[INET6_ADDRSTRLEN] = {0};
                inet_ntop(AF_INET6, &((struct sockaddr_in6 *)&remoteAddr)->sin6_addr, ip, INET6_ADDRSTRLEN);
                remoteAddress = [NSString stringWithUTF8String:ip];
            }
            if (remoteAddress) {
                record.ip = remoteAddress;
            }
            
            // 结果判断
            if ([TracerouteCommon isTimeoutPacket:buff len:(int)resultLen isIPv6:isIPv6]) {
                // 到达中间节点
                [durations addObject:@(duration)];
            } else if ([TracerouteCommon isEchoReplyPacket:buff len:(int)resultLen isIPv6:isIPv6] && [remoteAddress isEqualToString:_ipAddress]) {
                // 到达目标服务器
                [durations addObject:@(duration)];
                finished = YES;
            } else {
                // 失败
                [durations addObject:[NSNull null]];
            }
        }
    }
    record.recvDurations = [durations copy];
    
    if (!receiveReply) {
        ++_failOvertime;
    } else {
        _failOvertime = 0;
    }
    
    [_results addObject:record];
    
    // 回调每一步的结果
    if (_stepCallback) {
        _stepCallback(record);
    }
    NSLog(@"%@", record);
    
    return finished;
}

- (BOOL)validateReply {
    return YES;
}

@end
