//
//  Traceroute.m
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/8.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import "Traceroute.h"
#import "TracerouteCommon.h"

#define kTraceMaxAttempts 3 // 每一跳尝试的次数
#define kTraceRouteFailOvertime 30 // 连续失败最大次数
#define kTraceRoutePort 20000 // traceroute所用的端口号
#define kTraceMaxJump 30 // 跟Tracert一样最大30跳

@interface Traceroute()

@property (nonatomic) NSString* host;
@property (nonatomic) NSInteger maxTtl; // 最大跳数
@property (nonatomic) NSMutableArray<TracerouteRecord *>* results;
@property (nonatomic) BOOL isIPv6;
@property (nonatomic) NSInteger failOvertime; // 连续失败的次数

@property (nonatomic) TracerouteStepCallback stepCallback;
@property (nonatomic) TracerouteFinishCallback finishCallback;

@end

@implementation Traceroute

+ (instancetype)startTracerouteWithHost:(NSString *)host
                                 isIPv6:(BOOL)ipv6
                           stepCallback:(TracerouteStepCallback)stepCallback
                                 finish:(TracerouteFinishCallback)finish {
    Traceroute *traceroute = [[Traceroute alloc] initWithHost:host isIPv6:ipv6 maxTtl:kTraceMaxJump stepCallback:stepCallback finish:finish];
    [traceroute run];
    return traceroute;
}

- (instancetype)initWithHost:(NSString*)host
                      isIPv6:(BOOL)ipv6
                      maxTtl:(NSInteger)maxTtl
                stepCallback:(TracerouteStepCallback)stepCallback
                      finish:(TracerouteFinishCallback)finish {
    if (self = [super init]) {
        _host = host;
        _maxTtl = maxTtl;
        _isIPv6 = ipv6;
        _stepCallback = stepCallback;
        _finishCallback = finish;
        _results = [[NSMutableArray alloc] init];
        _failOvertime = 0;
    }
    return self;
}

#pragma mark - Private

- (void)run {
    // 目标主机地址
    struct sockaddr *remoteAddr = [TracerouteCommon makeSockaddrWithHost:_host.UTF8String
                                                                    port:(int)kTraceRoutePort
                                                                  isIPv6:_isIPv6];
    
    // 创建套接字
    int send_sock;
    if ((send_sock = socket(remoteAddr->sa_family, SOCK_DGRAM, _isIPv6 ? IPPROTO_ICMPV6 : IPPROTO_ICMP)) < 0) {
        if (_stepCallback) {
            _stepCallback(nil);
        }
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
        if (setsockopt(send_sock, IPPROTO_IP, IP_TTL, &ttl, sizeof(ttl)) < 0) {
            NSLog(@"setsockopt fail");
        }
        succeed = [self sendAndRecv:send_sock addr:remoteAddr ttl:ttl];
    } while (++ttl <= _maxTtl && !succeed);
    
    close(send_sock);
    
    // traceroute结束，回调结果
    if (_finishCallback) {
        _finishCallback([_results copy], succeed);
    }
}

- (BOOL)sendAndRecv:(int)sendSock
               addr:(struct sockaddr *)addr
                ttl:(int)ttl {
    char buff[200];
    BOOL finished = NO;
    
    // 构建icmp报文
    uint16_t identifier = (uint16_t)ttl;
    NSData *payload = [[NSString stringWithFormat:@"traceroute icmp packet %d", ttl] dataUsingEncoding:NSASCIIStringEncoding];
    NSData *packetData = [TracerouteCommon makeICMPPacketWithID:identifier
                                                       sequence:ttl
                                                        payload:payload
                                                       isICMPv6:_isIPv6];
    
    // 记录结果
    TracerouteRecord *record = [[TracerouteRecord alloc] init];
    record.ttl = ttl;
    record.total = kTraceMaxAttempts;
    
    BOOL receiveReply = NO;
    NSMutableArray *durations = [[NSMutableArray alloc] init];
    
    // 连续发送3个ICMP报文，测试速度
    for (int try = 0; try < kTraceMaxAttempts; try ++) {
        NSDate* startTime = [NSDate date];
        // 发送icmp报文
        ssize_t sent = sendto(sendSock, packetData.bytes, packetData.length, 0, (struct sockaddr*)addr, sizeof(struct sockaddr));
        if (sent < 0) {
            continue;
        }
        
        // 接收icmp数据
        struct sockaddr remoteAddr;
        socklen_t len = sizeof(remoteAddr);
        ssize_t res = recvfrom(sendSock, buff, sizeof(buff), 0, (struct sockaddr*)&remoteAddr, &len);
        if (res < 0) {
            break; // 为了保证速度出错直接break
        } else {
            receiveReply = YES;
            NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:startTime];
            
            // 解析IP地址
            NSString* remoteAddress = nil;
            if (remoteAddr.sa_family == AF_INET) {
                char ip[INET_ADDRSTRLEN] = {0};
                inet_ntop(AF_INET, &((struct sockaddr_in *)&remoteAddr)->sin_addr.s_addr, ip, sizeof(ip));
                remoteAddress = [NSString stringWithUTF8String:ip];
            } else if (remoteAddr.sa_family == AF_INET6) {
                char ip[INET6_ADDRSTRLEN] = {0};
                inet_ntop(AF_INET6, &((struct sockaddr_in6 *)&remoteAddr)->sin6_addr, ip, INET6_ADDRSTRLEN);
                remoteAddress = [NSString stringWithUTF8String:ip];
            }
            
            // record
            if (remoteAddress) {
                record.ip = remoteAddress;
            }
            record.success = YES;
            [durations addObject:@(duration)];
            
            ICMPPacket *icmpPacket = [TracerouteCommon unpackICMPPacket:buff len:(int)res];;
            
            if (icmpPacket != NULL && icmpPacket->type == kICMPv4TypeEchoReply && [remoteAddress isEqualToString:_host]) {
                finished = YES;// 找到目标服务器
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

@end
