//
//  VICCheckNetwork.m
//  VICNetworkKIt
//
//  Created by vic on 14-5-6.
//  Copyright (c) 2014年 vic. All rights reserved.
//
//  @version 0.1
//

#import "VICCheckNetwork.h"
#import "VICNetworkDefines.h"

@implementation VICCheckNetwork

/**
 *  检查网络是否连接
 *
 *  @return BOOL（YES 为连接，NO 为断开）
 */
+ (BOOL)isNetworkAvailable
{
    return ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable);
}



@end
