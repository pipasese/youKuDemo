//
//  ViewController.m
//  youKuDemo
//
//  Created by vic on 14-6-17.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "ViewController.h"
#import "VICNetworkEngine.h"
#import "YoukuUploader.h"
#import "AppDelegate.h"
#import "YoukuUploaderDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "JSONKit.h"
#import "videoViewController.h"


@interface ViewController ()

@end

@implementation ViewController
{
    //优酷授权得到的码，用来获取access_token
    NSString *code;
    
    VICNetworkEngine *a;
    //储存access_token
    NSDictionary *access;
    //储存已上传视频数据
    NSDictionary *vedios;
    //待上传文件路径
    NSString *mediaUrl;
    //进度条
    UIProgressView *prog;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    a=[[VICNetworkEngine alloc]initWithHostName:@"openapi.youku.com"];
    //添加button
    [self initbuttons];
    //获取本地的access_token信息，如果有，则不必授权，获取access_token，直接上传视频就好了
    [self checkAccessToken];
    //获取本地储存的已上传video信息
    [self checkvedio];
    //初始化进度条
    [self initProgress];

}

-(void)initProgress{
    
    //进度条视图
    UIView *mainprog=[[UIView alloc]initWithFrame:CGRectMake(10, 80, 330, 20)];
     mainprog.tag=10000;
    
    //进度条
    prog=[[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, 250, 20)];
    [prog setProgressViewStyle:UIProgressViewStyleDefault];
    
    //进度百分比
    UILabel *bfb=[[UILabel alloc]initWithFrame:CGRectMake(250, -10, 50, 20)];
    [bfb setTextColor:[UIColor blackColor]];
    [bfb setText:@" 0%"];
    bfb.tag=10001;
    
    [mainprog addSubview:bfb];
    [mainprog addSubview:prog];
    [self.view addSubview:mainprog];
}

-(void)initbuttons
{
    //选择视频文件button
    UIButton *getmedia=[[UIButton alloc]initWithFrame:CGRectMake(40, 100, 100, 30)];
    [getmedia setTitle:@"选择视频" forState:UIControlStateNormal];
    [getmedia setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [getmedia.layer setBorderWidth:2];
    [getmedia.layer setBorderColor:[[UIColor redColor] CGColor]];
    [getmedia addTarget:self action:@selector(LocalPhoto) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:getmedia];
    
    //上传button
    UIButton *uploadButton=[[UIButton alloc]initWithFrame:CGRectMake(40,150,100, 30)];
    //[uploadButton setBackgroundColor:[UIColor blueColor]];
    [uploadButton setTitle:@"上传" forState:UIControlStateNormal];
    [uploadButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [uploadButton.layer setBorderWidth:2];
    [uploadButton.layer setBorderColor:[[UIColor redColor] CGColor]];
    [uploadButton addTarget:self action:@selector(upload) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:uploadButton];
    
    //授权button,包括获取access_token
    UIButton *chance=[[UIButton alloc]initWithFrame:CGRectMake(40, 200, 100, 30)];
    [chance setTitle:@"获取权限" forState:UIControlStateNormal];
    [chance setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [chance.layer setBorderColor:[[UIColor blackColor] CGColor] ];
    [chance.layer setBorderWidth:2];
    [chance addTarget:self action:@selector(getcode) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:chance];

    //查看已上传视频
    UIButton *uploadedVedios=[[UIButton alloc]initWithFrame:CGRectMake(40, 250, 150, 30)];
    [uploadedVedios setTitle:@"查看已上传视频" forState:UIControlStateNormal];
    [uploadedVedios setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [uploadedVedios.layer setBorderColor:[[UIColor blackColor] CGColor] ];
    [uploadedVedios.layer setBorderWidth:2];
    [uploadedVedios addTarget:self action:@selector(getuploadedvedios) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:uploadedVedios];

}

-(void)getuploadedvedios{
    if (access!=Nil)
    {
        //更新视频信息
        [self vediosbyme];
    }
    //跳转到已上传视频信息页面；
    [self performSegueWithIdentifier:@"seevedio" sender:self];
    
}

//webview加载失败
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    //[[self.view viewWithTag:1003]removeFromSuperview];
}


//webview开始加载
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"url:%@",[request.URL absoluteString]);
    NSString *urlstr=[request.URL absoluteString];
    NSRange startrange=[urlstr rangeOfString:@"/?code="];
    NSRange endrange=[urlstr rangeOfString:@"&state"];
    NSRange denied=[urlstr rangeOfString:@"denied"];
    
    //判断是否是授权链接，根据跳转链接获取code
    if (startrange.length>0 && endrange.length>0) {
        NSString *codetmp=[urlstr substringWithRange:NSMakeRange(startrange.length+startrange.location, endrange.location-startrange.length-startrange.location)];
        NSLog(@"yeah,i get code:%@",codetmp);
        code=codetmp.length>0?codetmp:code;
       [[self.view viewWithTag:1003]removeFromSuperview];
        
        if (code.length>0) {
            //根据code获取access_token
            [self getAccess_token:code];
        }
        
        return NO;
    }
    
    if (denied.length>0) {
        return NO;
    }
    
    return  YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//获取code
-(void)getcode
{
    [[self.view viewWithTag:1001]removeFromSuperview];
    
    UIView *mainview=[[UIView alloc]initWithFrame:CGRectMake(0, 70,[UIScreen mainScreen].currentMode.size.width/2, [UIScreen mainScreen].currentMode.size.height)];
    mainview.tag=1003;
    
    UIWebView *webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 20, [UIScreen mainScreen].currentMode.size.width/2-10, [UIScreen mainScreen].currentMode.size.height/2-130)];
    webview.delegate=self;
    [webview setScalesPageToFit:NO];
    
    [mainview addSubview:webview];
    
    UIButton *cancelbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].currentMode.size.width/2, 30)];
    [cancelbutton setTitle:@"退出" forState:UIControlStateNormal];
    [cancelbutton setBackgroundColor:[UIColor redColor]];
    [cancelbutton addTarget:self action:@selector(cancellooking) forControlEvents:UIControlEventTouchDown];
    [mainview addSubview:cancelbutton];
    
    [self.view addSubview:mainview];

    SuccessBlock loginSuccess = ^(NSDictionary *responseDic){
        
        NSURL *url =[NSURL URLWithString: @"https://openapi.youku.com/v2/oauth2/authorize?client_id=571e6d9acffcb57e&response_type=code&redirect_uri=http://www.baidu.com&state=xyz"];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [webview loadRequest:request];
        
    };
    [a getyoukuWithApiPath:@"/v2/oauth2/authorize?client_id=571e6d9acffcb57e&response_type=code&redirect_uri=http://www.baidu.com&state=xyz" params:nil success:loginSuccess error:Nil progress:nil ssl:YES httpMethod:@"GET"];
}

//推出授权
-(void)cancellooking{
    [[self.view viewWithTag:1003]removeFromSuperview];
}


//获取accesstoken
-(void)getAccess_token:(NSString *)code
{
    SuccessBlock loginSuccess = ^(NSDictionary *responseDic){
        
    NSDictionary *accesstmp=[[responseDic valueForKey:@"html"] objectFromJSONString];

    if (accesstmp!=Nil) {
            access=accesstmp;
            [self saveAccessToken];
        }
    else
        {
            [self alert:@"get accesstoken failed" withtitle:@"oh sorry"];
        }
    };
    
    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
  
    [params setObject:client_id forKey:@"client_id"];
    [params setObject:client_secret forKey:@"client_secret"];
    [params setObject:@"authorization_code" forKey:@"grant_type"];
    [params setObject:code forKey:@"code"];
    [params setObject:@"http://www.baidu.com" forKey:@"redirect_uri"];
    
    [a getyoukuWithApiPath:@"/v2/oauth2/token" params:params success:loginSuccess error:Nil progress:Nil ssl:YES httpMethod:@"POST"];

}

//上传视频
-(void)upload{
    
    BOOL validAccesstoken=true;
    if ([[access valueForKey:@"access_token"]length]==0) {
        validAccesstoken=false;
        [self alert:@"we do not have access_token " withtitle:@"hello"];
    }
    if (mediaUrl ==Nil) {
        validAccesstoken=false;
        [self alert:@"we should choose the midia first " withtitle:@"hello" ];
    }
   // NSLog(@"%@",mediaUrl);
   // NSLog(@"%@",[access valueForKey:@"access_token"]);
    
    if (validAccesstoken==true) {
    NSMutableDictionary *params =[[NSMutableDictionary alloc]init];
    [params setObject:client_id forKey:@"client_id"];
    [params setObject:[access valueForKey:@"access_token"] forKey:@"access_token"];
    //优酷账号
    [params setObject:@"592679546@qq.com" forKey:@"username"];
    //优酷密码
    [params setObject:@"oo520123" forKey:@"password"];
    
    
    NSMutableDictionary *upload_info_params=[[NSMutableDictionary alloc]init];
    //视频标题
    [upload_info_params setObject:@"titie" forKey:@"title"];
    //视频标签
    [upload_info_params setObject:@"tags" forKey:@"tags"];
    //视频本地路径
    [upload_info_params setObject:mediaUrl forKey:@"file_name"];
    //视频md5值，经实践，sdk会自己算，所以这里随便传值即可
    [upload_info_params setObject:@"file_md5" forKey:@"file_md5"];
    //视频大小，经实践，sdk会自己算，所以这里随便传值即可
    [upload_info_params setObject:@"file_size" forKey:@"file_size"];
    /*
    其他参数
    category：string 可选参数 视频分类，详细分类定义见schemas/video/category，此链接查不到。。。
       
    copyright_type：string 可选参数 版权所有，默认值为’original’
                   ‘original’
                   ‘reproduced ‘
        
    public_type: string 可选参数 视频观看权限，默认值为 ‘all’
                 ‘all’：公开
                 ‘friend’：仅好友
                 ‘password’：需要输入密码才能观看
        
    watch_password：string 可选参数 观看明文密码，当public_type=password时，此参数为必选参数
    description：string 可选参数 视频描述，最多能写2000个字
    latitude：double 可选参数 地理纬度
    longitude：double 可选参数 地理经度
    shoot_time：datetime 可选参数 拍摄时间
    */
    [[YoukuUploader sharedInstance]upload:params uploadInfo:upload_info_params uploadDelegate:self  dispatchQueue:Nil];
    }
    
}

//检查accesstoken文件是否存在
-(void)checkAccessToken{
    NSString *filepath=[self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        access=[[NSMutableDictionary alloc]initWithContentsOfFile:filepath];
    }
}

//检查vedio文件是否存在
-(void)checkvedio{
    NSString *filepath=[self datavedioPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filepath]) {
        vedios=[[NSMutableDictionary alloc]initWithContentsOfFile:filepath];
    }
}

//获取存取accesstoken的文件路径
-(NSString *)dataFilePath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"accessTokenData.plist"];
}

//获取存取vedio的文件路径
-(NSString *)datavedioPath
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"vedio.plist"];
}

//保存access_token到本地
-(void)saveAccessToken{
   // NSLog(@"%@",access);
    
    NSString *path=[self dataFilePath];
    if ([access writeToFile:path atomically:YES]) {
        NSLog(@"save accesstoken success!");
    }
    else
    {
        NSLog(@"save accesstoken failed");
    }
    
}

-(void)alert:(NSString *)contents withtitle:(NSString *)title
{
    UIAlertView *alerta=[[UIAlertView alloc]initWithTitle:title message:contents delegate:Nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alerta show];
}

//打开本地相册获取视频
-(void)LocalPhoto

{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    [self presentModalViewController:picker animated:YES];
}

//本地相册选择视频之后触发
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    //获取媒体类型
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是否视频文件
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        //获取视频文件的url
        NSURL *mediaUrltmp = [info objectForKey:UIImagePickerControllerMediaURL];
        mediaUrl=[mediaUrltmp absoluteString];
        mediaUrl=[mediaUrl substringFromIndex:7];
        
        UIAlertView *loadorwatch=[[UIAlertView alloc]initWithTitle:@"同时" message:@"请问是想观看还是想上传" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"上传",@"看看", nil];
        [loadorwatch show];
    }
    [picker dismissModalViewControllerAnimated:YES];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    //上传
    if (buttonIndex==1)
    {
        [self upload];
    }
    //观看
    else if (buttonIndex==2)
    {
        [[self.view viewWithTag:1001]removeFromSuperview];
        
        UIView *mainview=[[UIView alloc]initWithFrame:CGRectMake(0, 20,[UIScreen mainScreen].currentMode.size.width/2, [UIScreen mainScreen].currentMode.size.height)];
        mainview.tag=1002;
        
        UIWebView *webview=[[UIWebView alloc]initWithFrame:CGRectMake(0, 30, [UIScreen mainScreen].currentMode.size.width/2, [UIScreen mainScreen].currentMode.size.height/2)];
        webview.delegate=self;
        
        [mainview addSubview:webview];
        
        UIButton *cancelbutton=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].currentMode.size.width/2, 30)];
        [cancelbutton setTitle:@"取消播放" forState:UIControlStateNormal];
        [cancelbutton setBackgroundColor:[UIColor redColor]];
        [cancelbutton addTarget:self action:@selector(cancelsc) forControlEvents:UIControlEventTouchDown];
        [mainview addSubview:cancelbutton];
        
        [self.view addSubview:mainview];
        NSURL *url =[NSURL URLWithString: mediaUrl];
        NSURLRequest *request =[NSURLRequest requestWithURL:url];
        [webview loadRequest:request];
        
    }
}

//取消观看
-(void)cancelsc{
    [[self.view viewWithTag:1002]removeFromSuperview];
}

//保存vedio信息到本地
-(void)savevedios
{
    
    NSString *path=[self datavedioPath];
   
    
    if ([vedios writeToFile:path atomically:YES]) {
        NSLog(@"save videos success!");
    }
    else
    {
        NSLog(@"save videos failed");
    }

}

//上传的视频信息，用appkey和accesstoken来取得
-(void)vediosbyme
{
    
    SuccessBlock loginSuccess = ^(NSDictionary *responseDic){
    
    NSDictionary *accesstmp=[[responseDic valueForKey:@"html"] objectFromJSONString];
    
    if (accesstmp!=Nil) {
        //如果取得视频信息，则替换并保存到本地
        vedios=accesstmp;
        [self savevedios];
    }
    else
    {
        [self alert:@"get accesstoken failed" withtitle:@"oh sorry"];
    }
};

    NSMutableDictionary *params=[[NSMutableDictionary alloc]init];
    
    [params setObject:client_id forKey:@"client_id"];
    [params setObject:[access valueForKey:@"access_token"] forKey:@"access_token"];
    
    //页面
    int page;
    //数量
    int count;
    page=1;
    count=100;
    //获取页面和数量下的视频信息
    [a getyoukuWithApiPath:[NSString stringWithFormat:@"/v2/videos/by_me.json?client_id=%@&access_token=%@&page=%d&count=%d",client_id,[access valueForKey:@"access_token"],page,count]params:nil success:loginSuccess error:Nil progress:Nil ssl:YES httpMethod:@"GET"];

}

//页面传值，将vedio信息传递给视频信息页面
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"seevedio"]) {
        videoViewController *videoa=segue.destinationViewController;
        videoa.movies=vedios;
    }
}

//更新进度条
- (void) onProgressUpdate:(int)progress{
    UILabel *labelbfba=[[self.view viewWithTag:10000] viewWithTag:10001];
    labelbfba.text=[NSString stringWithFormat:@"%d%%",progress];
    NSLog(@"%d%%",progress);
    float value=progress*0.01;
    [prog setProgress:value animated:YES];
    //NSLog(@"aaa");
}


//上传成功
- (void) onSuccess:(NSString*)vid
{
    if (access!=Nil)
    {
        //更新视频信息
        [self vediosbyme];
    }
    [self alert:[NSString stringWithFormat:@"upload success,the video id : %@",vid] withtitle:@"now"];
}


//上传失败
- (void) onFailure:(NSDictionary*)response
{
    [self alert:[NSString stringWithFormat:@"type:%@,desc:%@,code:%@",[response valueForKey:@"type"],[response valueForKey:@"desc"],[response valueForKey:@"code"]] withtitle:@"failed"];
}


@end
