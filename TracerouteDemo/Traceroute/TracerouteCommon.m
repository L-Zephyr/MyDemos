//
//  TracerouteCommon.m
//  TracerouteDemo
//
//  Created by LZephyr on 2018/2/7.
//  Copyright © 2018年 LZephyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssertMacros.h>
#import "TracerouteCommon.h"

// 编译期检查
__Check_Compile_Time(sizeof(IPHeader) == 20);
__Check_Compile_Time(offsetof(IPHeader, versionAndHeaderLength) == 0);
__Check_Compile_Time(offsetof(IPHeader, differentiatedServices) == 1);
__Check_Compile_Time(offsetof(IPHeader, totalLength) == 2);
__Check_Compile_Time(offsetof(IPHeader, identification) == 4);
__Check_Compile_Time(offsetof(IPHeader, flagsAndFragmentOffset) == 6);
__Check_Compile_Time(offsetof(IPHeader, timeToLive) == 8);
__Check_Compile_Time(offsetof(IPHeader, protocol) == 9);
__Check_Compile_Time(offsetof(IPHeader, headerChecksum) == 10);
__Check_Compile_Time(offsetof(IPHeader, sourceAddress) == 12);
__Check_Compile_Time(offsetof(IPHeader, destinationAddress) == 16);
__Check_Compile_Time(sizeof(ICMPPacket) == 8);
__Check_Compile_Time(offsetof(ICMPPacket, type) == 0);
__Check_Compile_Time(offsetof(ICMPPacket, code) == 1);
__Check_Compile_Time(offsetof(ICMPPacket, checksum) == 2);
__Check_Compile_Time(offsetof(ICMPPacket, identifier) == 4);
__Check_Compile_Time(offsetof(ICMPPacket, sequenceNumber) == 6);

@implementation TracerouteCommon

// 来源于官方示例：https://developer.apple.com/library/content/samplecode/SimplePing/Introduction/Intro.html
+ (uint16_t)makeChecksumFor:(const void *)buffer len:(size_t)bufferLen {
    size_t bytesLeft;
    int32_t sum;
    const uint16_t *cursor;
    union {
        uint16_t us;
        uint8_t uc[2];
    } last;
    uint16_t answer;
    
    bytesLeft = bufferLen;
    sum = 0;
    cursor = buffer;
    
    /*
     * Our algorithm is simple, using a 32 bit accumulator (sum), we add
     * sequential 16 bit words to it, and at the end, fold back all the
     * carry bits from the top 16 bits into the lower 16 bits.
     */
    while (bytesLeft > 1) {
        sum += *cursor;
        cursor += 1;
        bytesLeft -= 2;
    }
    
    /* mop up an odd byte, if necessary */
    if (bytesLeft == 1) {
        last.uc[0] = *(const uint8_t *)cursor;
        last.uc[1] = 0;
        sum += last.us;
    }
    
    /* add back carry outs from top 16 bits to low 16 bits */
    sum = (sum >> 16) + (sum & 0xffff); /* add hi 16 to low 16 */
    sum += (sum >> 16); /* add carry */
    answer = (uint16_t)~sum; /* truncate to 16 bits */
    
    return answer;
}

+ (struct sockaddr *)makeSockaddrWithHost:(const void *)host port:(int)port isIPv6:(BOOL)isIPv6 {
    NSData *addrData = nil;
    if (isIPv6) {
        struct sockaddr_in6 nativeAddr6;
        memset(&nativeAddr6, 0, sizeof(nativeAddr6));
        nativeAddr6.sin6_len = sizeof(nativeAddr6);
        nativeAddr6.sin6_family = AF_INET6;
        nativeAddr6.sin6_port = htons(port);
        inet_pton(AF_INET6, host, &nativeAddr6.sin6_addr);
        addrData = [NSData dataWithBytes:&nativeAddr6 length:sizeof(nativeAddr6)];
    } else {
        struct sockaddr_in nativeAddr4;
        memset(&nativeAddr4, 0, sizeof(nativeAddr4));
        nativeAddr4.sin_len = sizeof(nativeAddr4);
        nativeAddr4.sin_family = AF_INET;
        nativeAddr4.sin_port = htons(port);
        if (host != NULL) {
            inet_pton(AF_INET, host, &nativeAddr4.sin_addr.s_addr);
        } else {
            nativeAddr4.sin_addr.s_addr = htonl(INADDR_ANY);
        }
        addrData = [NSData dataWithBytes:&nativeAddr4 length:sizeof(nativeAddr4)];
    }
    return (struct sockaddr *)[addrData bytes];
}

+ (NSData *)makeICMPPacketWithID:(uint16_t)identifier
                        sequence:(uint16_t)seq
                         payload:(NSData *)payload
                        isICMPv6:(BOOL)isICMPv6 {
    NSMutableData *         packet;
    ICMPPacket *            icmpPtr;
    
    packet = [NSMutableData dataWithLength:sizeof(*icmpPtr) + payload.length];
    assert(packet != nil);
    
    icmpPtr = packet.mutableBytes;
    icmpPtr->type = isICMPv6 ? kICMPv6TypeEchoRequest : kICMPv4TypeEchoRequest;
    icmpPtr->code = 0;
    icmpPtr->checksum = 0;
    icmpPtr->identifier     = OSSwapHostToBigInt16(identifier);
    icmpPtr->sequenceNumber = OSSwapHostToBigInt16(seq);
    memcpy(&icmpPtr[1], [payload bytes], [payload length]);
    
    if (!isICMPv6) {
        icmpPtr->checksum = [TracerouteCommon makeChecksumFor:packet.bytes len:packet.length];
    }
    
    return packet;
}

+ (ICMPPacket *)unpackICMPPacket:(char *)packet len:(int)len {
    if (len < (sizeof(IPHeader) + sizeof(ICMPPacket))) {
        return NULL;
    }
    const struct IPHeader *ipPtr = (const IPHeader *)packet;
    if ((ipPtr->versionAndHeaderLength & 0xF0) != 0x40 || // IPv4
        ipPtr->protocol != 1) { //ICMP
        return NULL;
    }
    size_t ipHeaderLength = (ipPtr->versionAndHeaderLength & 0x0F) * sizeof(uint32_t);
    
    if (len < ipHeaderLength + sizeof(ICMPPacket)) {
        return NULL;
    }
    
    return (ICMPPacket *)((char *)packet + ipHeaderLength);
}

@end
