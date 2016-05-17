//
//  LoginViewController.m
//  RACTest
//
//  Created by Madis on 16/5/17.
//
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *regBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationItem.title = @"首页";
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

/*-------------------------------------map---------------------------------------*/
    RACSignal *accountSignal = [_accountTextField.rac_textSignal map:^NSNumber *(NSString *value) {
        //判断账号有效性等
        return @(value.length >3);
    }];
    
    //    [[signal map:^id(id value) {
    //        return [value boolValue] ?[UIColor redColor]:[UIColor yellowColor];
    //    }] subscribeNext:^(id x) {
    //        _accountTextField.backgroundColor = x;
    //    }];
    
    //RAC,keypath
    RAC(_accountTextField, backgroundColor) = [accountSignal map:^id(NSNumber* value) {
        return [value boolValue] ?[UIColor yellowColor]:[UIColor clearColor];
    }];
    
/*---------------------combineLatest------------------------reduce-------------------------------*/
    RACSignal *passwordSignal = [_passwordTextField.rac_textSignal map:^NSNumber *(NSString *value) {
        return @(value.length >3);
    }];
    RACSignal *combineSignal = [RACSignal combineLatest:@[accountSignal,passwordSignal] reduce:^id(NSNumber *signalA,NSNumber *signalB){
        return @([signalA boolValue] &&[signalB boolValue]);
    }];
    [combineSignal subscribeNext:^(id x) {
        _loginBtn.backgroundColor = [x boolValue]? [UIColor redColor]:[UIColor lightGrayColor];
        _loginBtn.enabled = [x boolValue];
    }];
    
/*-------------------------------------_loginBtn---------------------------------------*/
    
    [[_loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        MSLog(@"李磊---login");
        [self.view endEditing:YES];
        [[[UIAlertView alloc] initWithTitle:nil message:@"登陆成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
    }];
}
- (IBAction)regBtnClick:(id)sender {
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
