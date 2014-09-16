//
//  VICNetworkEngine.m
//  VICNetworkKIt
//
//  Created by vic on 14-5-6.
//  Copyright (c) 2014年 vic. All rights reserved.
//
//  @version 0.1
//

#import "VICNetworkEngine.h"
#import "MKNetworkKit/MKNetworkEngine.h"

#define SUCCESS_RETURN_CODE_NUMBER          0
//#define DATA_EXCEPTION_RETURN_CODE_NUMBER   90001
//#define NEED_LOGIN_RETURN_CODE_NUMBER       90002
//#define NO_POWER__RETURN_CODE_NUMBER        90003
//#define SYSTEM_EXCEPTION_RETURN_CODE_NUMBER 99999

//Notification Center
//  showErrorMessage 带一个NSDictionary参数
//  showWebErrorAlertView
//  showWebSuccessNotification

@implementation VICNetworkEngine

/**
 *  向服务端发起请求并获得返回数据
 *
 *  @param apiPath       接口api地址(不包括HostName)
 *  @param params        http请求需要的参数
 *  @param successBlock  请求成功回调此Block(传入一个NSDictionary类型的参数)
 *  @param errorBlock    请求失败回调此Block(传入一个NSError类型的参数)
 *  @param progressBlock 请求过程中的进度条(传入一个double类型的参数)
 */
- (void)getDataWithApiPath:(NSString *)apiPath
                    params:(NSDictionary *)params
                   success:(SuccessBlock)successBlock
                     error:(ErrorBlock)errorBlock
                  progress:(ProgressBlock)progressBlock
                       sssl:(BOOL)sssl
{
    NSAssert(apiPath != nil, @"\u274C 传入参数错误，apiPath 为空");
    NSAssert(params != nil, @"\u274C 传入参数错误，params 为空");

    if (![VICCheckNetwork isNetworkAvailable]) {
        DLog(@"\u274C 无法连接到网络");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        return ;
    }
    
//VICNetworkOperation *operation = (VICNetworkOperation *)[self operationWithPath:apiPath params:params httpMethod:@"POST"];
    
    VICNetworkOperation *operation=(VICNetworkOperation *)[self operationWithPath:apiPath params:params httpMethod:@"POST" ssl:sssl];
   
    
    [operation addHeader:@"Content-Type" withValue:@"application/json"];
    [operation addHeader:@"Accept" withValue:@"application/json"];
    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];

    
    // operation 完成时调用
    [operation addCompletionHandler:^(MKNetworkOperation *completedSuccess) {
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[completedSuccess responseData]
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];

        BOOL success = YES;
        int code = [[responseDic valueForKey:@"code"] intValue];
        if (code != SUCCESS_RETURN_CODE_NUMBER) {
            success = NO;
            DLog(@"\u274C 返回异常，code: %i message: %@",code, [responseDic valueForKey:@"message"]);
        }
        if (error != nil) {
            success = NO;
            DLog(@"\u274C JSON解析失败: %@",error);
        }

        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebSuccessNotification" object:nil];
            if (successBlock != nil) {
                successBlock(responseDic);
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showErrorMessage" object:responseDic];
            if (errorBlock != nil) {
                errorBlock(error);
            }
        }
    } errorHandler:^(MKNetworkOperation *comletedError, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];

    [self enqueueOperation:operation];
}

/**
 *  从服务端下载文件存至指定的目录
 *
 *  @param apiPath       接口api地址(不包括HostName)
 *  @param params        http请求需要的参数
 *  @param filePath      将下载的文件保存在此目录
 *  @param successBlock  下载成功回调此Block(没有参数)
 *  @param errorBlock    下载失败回调此Block(传入一个NSError类型的参数)
 *  @param progressBlock 下载进度条(传入一个double类型的参数)
 */
- (void)getDataWithApiPath:(NSString *)apiPath
                    params:(NSDictionary *)params
                  filePath:(NSString *)filePath
        successWithoutArgu:(SuccessBlockWithoutArgs)successBlock
                     error:(ErrorBlock)errorBlock
                  progress:(ProgressBlock)progressBlock
{
    NSAssert(apiPath != nil, @"\u274C 传入参数错误，apiPath 为空");
    NSAssert(params != nil, @"\u274C 传入参数错误，params 为空");

    if (![VICCheckNetwork isNetworkAvailable]) {
        DLog(@"\u274C 无法连接到网络");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        return ;
    }

    VICNetworkOperation *operation = (VICNetworkOperation *)[self operationWithPath:apiPath params:params httpMethod:@"POST"];

    [operation addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath append:NO]];
    if (progressBlock != nil){
        [operation onDownloadProgressChanged:^(double progress){
            progressBlock(progress);
        }];
    };

    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebSuccessNotification" object:nil];
        
        if (successBlock != nil) {
            successBlock();
        }
        DLog(@"下载文件类型 %@",[[[completedOperation readonlyResponse] allHeaderFields] valueForKey:@"Content-Type"]);
    }errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
    }];

    [self enqueueOperation:operation];
}



/**
 *  向微信服务端发起请求并获得返回数据
 *
 *  @param apiPath       接口api地址(不包括HostName)
 *  @param params        http请求需要的参数
 *  @param successBlock  请求成功回调此Block(传入一个NSDictionary类型的参数)
 *  @param errorBlock    请求失败回调此Block(传入一个NSError类型的参数)
 *  @param progressBlock 请求过程中的进度条(传入一个double类型的参数)
 *  @param ssl           yes为https，no为http
 *  @param httpMethod    GET/POST
 */
- (void)getWXWithApiPath:(NSString *)apiPath
                    params:(NSDictionary *)params
                   success:(SuccessBlock)successBlock
                     error:(ErrorBlock)errorBlock
                  progress:(ProgressBlock)progressBlock
                       ssl:(BOOL)ssl
                httpMethod:(NSString *)httpMethod
{
    NSAssert(apiPath != nil, @"\u274C 传入参数错误，apiPath 为空");
    if ([httpMethod isEqualToString:@"POST"]) {
    NSAssert(params != nil, @"\u274C 传入参数错误，params 为空");
    }
    
    if (![VICCheckNetwork isNetworkAvailable]) {
        DLog(@"\u274C 无法连接到网络");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        return ;
    }
    
    VICNetworkOperation *operation=(VICNetworkOperation *)[self operationWithPath:apiPath params:params httpMethod:httpMethod ssl:ssl];
  
    //增加headerfields
    [operation addHeader:@"Content-Type" withValue:@"application/json"];
    [operation addHeader:@"Accept" withValue:@"application/json"];
    
    //设置params为json类型
    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    // operation 完成时调用
    [operation addCompletionHandler:^(MKNetworkOperation *completedSuccess) {
        NSError *error = nil;
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:[completedSuccess responseData]
                                                                    options:NSJSONReadingMutableLeaves
                                                                      error:&error];
        
        BOOL success = YES;
        int code = [[responseDic valueForKey:@"code"] intValue];
        if (code != SUCCESS_RETURN_CODE_NUMBER) {
            success = NO;
            DLog(@"\u274C 返回异常，code: %i message: %@",code, [responseDic valueForKey:@"message"]);
        }
        
        if (error != nil) {
            success = NO;
            DLog(@"\u274C JSON解析失败: %@",error);
        }
        
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebSuccessNotification" object:nil];
            if (successBlock != nil) {
                successBlock(responseDic);
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showErrorMessage" object:responseDic];
            if (errorBlock != nil) {
                errorBlock(error);
            }
        }
    } errorHandler:^(MKNetworkOperation *comletedError, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    
    [self enqueueOperation:operation];
}




/**
 *  向youku服务端发起请求并获得返回数据
 *
 *  @param apiPath       接口api地址(不包括HostName)
 *  @param params        http请求需要的参数
 *  @param successBlock  请求成功回调此Block(传入一个NSDictionary类型的参数)
 *  @param errorBlock    请求失败回调此Block(传入一个NSError类型的参数)
 *  @param progressBlock 请求过程中的进度条(传入一个double类型的参数)
 *  @param ssl           yes为https，no为http
 *  @param httpMethod    GET/POST
 */
- (void)getyoukuWithApiPath:(NSString *)apiPath
                  params:(NSDictionary *)params
                 success:(SuccessBlock)successBlock
                   error:(ErrorBlock)errorBlock
                progress:(ProgressBlock)progressBlock
                     ssl:(BOOL)ssl
              httpMethod:(NSString *)httpMethod
{
    NSAssert(apiPath != nil, @"\u274C 传入参数错误，apiPath 为空");
    if ([httpMethod isEqualToString:@"POST"]) {
        NSAssert(params != nil, @"\u274C 传入参数错误，params 为空");
    }
    
    if (![VICCheckNetwork isNetworkAvailable]) {
        DLog(@"\u274C 无法连接到网络");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        return ;
    }
    
    VICNetworkOperation *operation=(VICNetworkOperation *)[self operationWithPath:apiPath params:params httpMethod:httpMethod ssl:ssl];
    
    //增加headerfields
//    [operation addHeader:@"Content-Type" withValue:@"application/json"];
//    [operation addHeader:@"Accept" withValue:@"application/json"];
//    
    //设置params为json类型
//    [operation setPostDataEncoding:MKNKPostDataEncodingTypeJSON];
    
    // operation 完成时调用
    [operation addCompletionHandler:^(MKNetworkOperation *completedSuccess) {
        
        
        
       // NSLog([completedSuccess responseString]);
        NSError *error = nil;
        NSDictionary *responseDic = [[NSDictionary alloc]initWithObjectsAndKeys:[completedSuccess responseString],@"html",Nil];
        
        BOOL success = YES;
       
  
        if (success) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebSuccessNotification" object:nil];
            if (successBlock != nil) {
                successBlock(responseDic);
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"showErrorMessage" object:responseDic];
            if (errorBlock != nil) {
                errorBlock(error);
            }
        }
    } errorHandler:^(MKNetworkOperation *comletedError, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"showWebErrorAlertView" object:nil];
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    
    [self enqueueOperation:operation];
}




/**
 *  取消所有操作
 */
- (void)cancelAllOperations
{
    [super cancelAllOperations];
}

/**
 *  根据接口地址取消操作
 *
 *  @param apiPath 接口api地址
 */
- (void)cancelOperationWithApiPath:(NSString *)apiPath
{
    [VICNetworkEngine cancelOperationsContainingURLString:apiPath];
}

@end
