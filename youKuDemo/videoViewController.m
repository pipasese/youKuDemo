//
//  videoViewController.m
//  youKuDemo
//
//  Created by vic on 14-6-19.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "videoViewController.h"

@interface videoViewController ()

@end


@implementation videoViewController
{
    NSMutableDictionary *mv;
}
@synthesize movies;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mv=[movies valueForKey:@"videos"];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [mv count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //设置cell的代理，用来检测cell的拖拽事件
    
    //NSInteger *i=indexPath.row;
    NSString *title=[[mv valueForKey:@"title"] objectAtIndex:indexPath.row];
    //NSString *published=[[mv valueForKey:@"published"] objectAtIndex:indexPath.row] ;
    NSString *state=[[mv valueForKey:@"state"] objectAtIndex:indexPath.row];
    if ([state isEqualToString:@"normal"]) {
        state=@"正常";
    }
    else    if ([state isEqualToString:@"encoding"]) {
            state=@"转码中";
        }
    else    if ([state isEqualToString:@"fail"]) {
            state=@"转码失败";
        }
    else    if ([state isEqualToString:@"in_review"]) {
            state=@"审核中";
        }
    else    if ([state isEqualToString:@"blocked"]) {
            state=@"已屏蔽";
        }
    
    /*
     
     参数                 类型           允许为空        示例
     id                 string          false	 	视频唯一ID
     title              string          false	 	视频标题
     link               string          false	 	视频播放链接
     thumbnail          string          false	 	视频截图
     duration           int             false	 	视频时长，单位：秒
     category           string          false	 	视频分类
     state              string          false	 	视频状态 normal: 正常 encoding: 转码中 fail: 转码失败 in_review: 审核中 blocked: 已屏蔽
     published          string          false	 	发布时间
     description        string          true	 	视频描述
     player             string          false	 	播放器
     public_type        string          false	 	公开类型 all: 公开 friend: 仅好友观看 password: 输入密码观看
     copyright_type     string          false	 	版权所有 original: 原创 reproduced: 转载
     user               object          false	 	上传用户对象
     operation_limit	array           true	 	操作限制 COMMENT_DISABLED: 禁评论 DOWNLOAD_DISABLED: 禁下载
     streamtypes        array           true	 	视频格式 flvhd flv 3gphd 3gp hd hd2
     
     */

    cell.textLabel.text=[NSString stringWithFormat:@"标题：%@   状态：%@",title,state];
    //[title stringByAppendingString:published];
    
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[self.view viewWithTag:1001]removeFromSuperview];
    
    UIView *mainview=[[UIView alloc]initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].currentMode.size.width/2, [UIScreen mainScreen].currentMode.size.height)];
    mainview.tag=1003;
    
    UIWebView *webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].currentMode.size.width/2-10, [UIScreen mainScreen].currentMode.size.height/2-130)];
    webview.delegate=self;
    [webview setScalesPageToFit:YES];
    
    [mainview addSubview:webview];
    
    UIButton *cancelbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].currentMode.size.width/2, 30)];
    [cancelbutton setTitle:@"取消播放" forState:UIControlStateNormal];
    [cancelbutton setBackgroundColor:[UIColor redColor]];
    [cancelbutton addTarget:self action:@selector(cancellooking) forControlEvents:UIControlEventTouchDown];
    [mainview addSubview:cancelbutton];
    
    [self.view addSubview:mainview];

    NSString *mvid=[[mv valueForKey:@"id"] objectAtIndex:indexPath.row];
    
    NSString *htmldata=[NSString stringWithFormat:@"<iframe height=480 width=400 src=\"http://player.youku.com/embed/%@\" frameborder=0 allowfullscreen></iframe>",mvid];
    
    [webview loadHTMLString:htmldata baseURL:[NSURL fileURLWithPath: [[NSBundle mainBundle]  bundlePath]]];
    
}


-(void)cancellooking{
    [[self.view viewWithTag:1003]removeFromSuperview];
}




@end
