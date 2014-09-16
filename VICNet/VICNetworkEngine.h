//
//  VICNetworkEngine.h
//  VICNetworkKIt
//
//  Created by vic on 14-5-6.
//  Copyright (c) 2014年 vic. All rights reserved.
//
//  @version 0.1
//

#import "VICCheckNetwork.h"
#import "VICNetworkDefines.h"
#import "VICNetworkOperation.h"

//请求失败后调用此block，包含一个NSError参数
typedef void (^ErrorBlock) (NSError *error);

//请求过程中进度发生改变时调用此block，包含一个double参数
typedef void (^ProgressBlock) (double progress);

//请求成功后调用此block，包含一个NSDictionary参数
typedef void (^SuccessBlock) (NSDictionary *responseDic);

//请求成功后调用此block，没有参数
typedef void (^SuccessBlockWithoutArgs) ();

@interface VICNetworkEngine : MKNetworkEngine

- (void)cancelAllOperations;

- (void)cancelOperationWithApiPath:(NSString *)apiPath;

- (void)getDataWithApiPath:(NSString *)apiPath
                    params:(NSDictionary *)params
                   success:(SuccessBlock)successBlock
                     error:(ErrorBlock)errorBlock
                  progress:(ProgressBlock)progressBlock;

- (void)getDataWithApiPath:(NSString *)apiPath
                    params:(NSDictionary *)params
                  filePath:(NSString *)filePath
        successWithoutArgu:(SuccessBlockWithoutArgs)successBlock
                     error:(ErrorBlock)errorBlock
                  progress:(ProgressBlock)progressBlock;

- (void)getWXWithApiPath:(NSString *)apiPath
                        params:(NSDictionary *)params
                       success:(SuccessBlock)successBlock
                         error:(ErrorBlock)errorBlock
                      progress:(ProgressBlock)progressBlock
                            ssl:(BOOL)ssl
                    httpMethod:(NSString *)httpMethod;

- (void)getyoukuWithApiPath:(NSString *)apiPath
                  params:(NSDictionary *)params
                 success:(SuccessBlock)successBlock
                   error:(ErrorBlock)errorBlock
                progress:(ProgressBlock)progressBlock
                     ssl:(BOOL)ssl
              httpMethod:(NSString *)httpMethod;


@end
