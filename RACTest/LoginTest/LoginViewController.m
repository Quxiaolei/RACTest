//
//  LoginViewController.m
//  RACTest
//
//  Created by Madis on 16/5/17.
//
//

#import "LoginViewController.h"
#import "TableViewController.h"

@interface LoginViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"首页";
/*----------------------------------------------------------------------------*/
    //一直订阅信号,每次都做判断,不必要进行
//    [_accountTextField.rac_textSignal subscribeNext:^(id x) {
//        NSString *str = (NSString *)x;
//        if(str.length >3){
//            MSLog(@"李磊---长度大于3的-%@",x);
//        }
//        MSLog(@"李磊----%@",x);
//    }];
    
/*---------------------------------filter-------------------------------------------*/
//    [[_accountTextField.rac_textSignal filter:^BOOL(NSString *value) {
////        NSString *str =  (NSString *)value;
//        return value.length >3;
//    }] subscribeNext:^(id x) {
//        MSLog(@"李磊----大于3位的:%@",x);
//    }];
    
/*----------------------map--------------------------------filter---------------------*/
    //map:将已获取的数据做些操作
    //NSString->NSNumber
//    [[[_accountTextField.rac_textSignal map:^NSNumber *(NSString *value) {
//        //判断账号有效性等
//        return @(value.length);
//    }] filter:^BOOL(NSNumber *value) {
//        return [value integerValue] > 3;
//    }] subscribeNext:^(NSNumber *x) {
//        MSLog(@"李磊--next:%@",x);
//    }];

/*-------------NSString--------------------map--------------------NSNumber-------------------*/
    RACSignal *accountSignal = [_accountTextField.rac_textSignal map:^NSNumber *(NSString *value) {
        //判断账号有效性等
        return @(value.length >3);
    }];
    
    //    [[signal map:^id(id value) {
    //        return [value boolValue] ?[UIColor redColor]:[UIColor yellowColor];
    //    }] subscribeNext:^(id x) {
    //        _accountTextField.backgroundColor = x;
    //    }];
    
    //!!!:  KVO,RAC,keypath
    RAC(_accountTextField, backgroundColor) = [accountSignal map:^id(NSNumber* value) {
        return [value boolValue] ?[UIColor yellowColor]:[UIColor clearColor];
    }];
    
/*---------------------combineLatest------------------------reduce-------------------------------*/
    RACSignal *passwordSignal = [_passwordTextField.rac_textSignal map:^NSNumber *(NSString *value) {
        return @(value.length >3);
    }];
    RACSignal *combineSignal = [[RACSignal combineLatest:@[accountSignal,passwordSignal] reduce:^id(NSNumber *signalA,NSNumber *signalB){
        return @([signalA boolValue] &&[signalB boolValue]);
    }] distinctUntilChanged];
    //distinctUntilChanged,当前状态一直不可用时,不会subscribeNext操作
    @weakify(self);
    [combineSignal subscribeNext:^(id x) {
        @strongify(self);
        self.loginBtn.backgroundColor = [x boolValue]? [UIColor redColor]:[UIColor lightGrayColor];
        self.loginBtn.enabled = [x boolValue];
    }];
    
/*----------------------------merge-------------任何一个signal改变都会subscribe----------------------*/
    [[accountSignal merge:passwordSignal] subscribeNext:^(id x) {
        MSLog(@"李磊--merge--%@",x);
    }];
    
/*-------------------------------------_loginBtn---------------------------------------*/
//    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
//        MSLog(@"李磊---login");
//        [self.view endEditing:YES];
////        [[[UIAlertView alloc] initWithTitle:nil message:@"登陆成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
////        TableViewController *vc = [[TableViewController alloc]init];
////        [self.navigationController pushViewController:vc animated:YES];
//    }];
/*-------------------------------------_loginBtn-------->>>>target-action-------------------------------*/
    //当_accountTextField和_passwordTextField正在校验时，登录按钮不可点击,防止用户多次执行登录操作
    //!!!:  target-action
    [[[[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        _loginBtn.enabled = NO;
    }]
      //在主线程中执行
      deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(id x) {
        @strongify(self);
        MSLog(@"李磊---login");
        TableViewController *vc = [[TableViewController alloc]init];
        [self.navigationController pushViewController:vc animated:YES];
        //模拟登陆成功
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _loginBtn.enabled = YES;
        });
    }];
    
/*-------------------------------------通知----------------------------------------*/
    //!!!:  通知
    [[[NSNotificationCenter defaultCenter]
      rac_addObserverForName:UIKeyboardDidShowNotification object:nil]
     subscribeNext:^(NSNotification *notification) {
         MSLog(@"李磊----键盘弹起");
     }];
    
/*-------------------------------------分线程加载图片----------------------------------------*/
    [[self loadImageOnBackGround] subscribeNext:^(NSData *x) {
//        (lldb) po [RACScheduler currentScheduler]
//        <RACTargetQueueScheduler: 0x7fb5d1c2a820> com.ReactiveCocoa.RACScheduler.backgroundScheduler
        @strongify(self);
        self.imageView.image = [UIImage imageWithData:x];
        MSLog(@"李磊---图片更换.......");
    } error:^(NSError *error) {
        MSLog(@"李磊---图片更换---%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊---图片更换---完成");
    }];
    
}
/*!
 *  @author madis, 16-05-18 18:05:47
 *
 *  分线程加载图片
 *
 *  @return signal包含有imageData
 */
- (RACSignal *)loadImageOnBackGround
{
//    (lldb) po [RACScheduler mainThreadScheduler]
//    <RACTargetQueueScheduler: 0x7fb5d1c0f210> com.ReactiveCocoa.RACScheduler.mainThreadScheduler
//    (lldb) po [RACScheduler currentScheduler]
//    <RACTargetQueueScheduler: 0x7fb5d1c2a820> com.ReactiveCocoa.RACScheduler.backgroundScheduler
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    NSError *error = [NSError errorWithDomain:@"loadImageOnBackGround" code:404 userInfo:nil];
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1671576656,1573074395&fm=116&gp=0.jpg"]];
        if (!imageData) {
            [subscriber sendError:error];
        }
        [subscriber sendNext:imageData];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}
- (IBAction)regBtnClick:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册测试" message:@"取消/确定?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alertView show];
    
    //!!!:  代理方法
    //    RACTuple,tuple:元组,对应delegate传入的参数alertView和buttonIndex
    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple *x) {
        // 实现 webViewDidStartLoad: 代理方法
        MSLog(@"李磊----%@\n%@\n%@",x,x.first,x.second);
    }];
    
//    //!!!: target-action
//    [alertView.rac_buttonClickedSignal subscribeNext:^(id x) {
//        MSLog(@"李磊----%@",x);
//        MSLog([x integerValue] ==0 ?@"李磊---取消按钮":@"李磊---确定按钮");
//    } error:^(NSError *error) {
//        MSLog(@"李磊----%@",error.localizedDescription);
//    } completed:^{
//        MSLog(@"李磊---完成");
//    }];
}
//不使用传统事件时,需要将事件xib target消除
//- (IBAction)loginBtnClick:(id)sender {
//    MSLog(@"李磊---传统点击事件");
//}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
