//
//  ViewController.h
//  youKuDemo
//
//  Created by vic on 14-6-17.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

//更新进度
- (void) onProgressUpdate:(int)progress;
//上传成功
- (void) onSuccess:(NSString*)vid;
//上传失败
- (void) onFailure:(NSDictionary*)response;

@end
