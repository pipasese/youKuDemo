//
//  VICNetworkDefines.h
//  VICNetworkKIt
//
//  Created by vic on 14-5-6.
//  Copyright (c) 2014年 vic. All rights reserved.
//
//  @version 0.1
//

#import "MKNetworkKit.h"

#ifdef DEBUG
#ifndef DLog
#   define DLog(fmt, ...) {NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);}
#endif
#ifndef ELog
#   define ELog(err) {if(err) DLog(@"%@", err)}
#endif
#else
#ifndef DLog
#   define DLog(...)
#endif
#ifndef ELog
#   define ELog(err)
#endif
#endif
