//
//  ViewController.m
//  RACTest
//
//  Created by Madis on 16/5/11.
//
//

#import "ViewController.h"
#import "TableViewController.h"
static NSString * const cellIdentifier = @"cell";

@interface ViewController ()
<UITableViewDelegate,
UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray<NSString *> *cellNameArray;

@property (nonatomic,strong) NSNumber *input;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _input = @111111111;
    _cellNameArray = @[@"concat",@"zipWith",@"then",@"merge",@"combineLatest",@"reduce",@"filter",@"ignoreSignal",@"distinctUntilChanged"];
    
    [self createView];
}
- (void)createView
{
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight-64)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    [self.view addSubview:_tableView];
}

#pragma mark - tableView delegate&dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellNameArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.textLabel.text = _cellNameArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.row) {
        case 0: [self concatSignal]; break;
        case 1: [self zipWithSignal]; break;
        case 2: [self thenSignal]; break;
        case 3: [self mergeSignal]; break;
        case 4: [self combineLatestSignal]; break;
        case 5: [self reduceSignal]; break;
        case 6: [self filterSignal]; break;
        case 7: [self ignoreSignal]; break;
        case 8: [self distinctUntilChangedSignal]; break;

        default:break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - RAC
/*!
 *  @author madis, 16-05-11 10:05:08
 *
 *  concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号。
 */

// 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活。
// concat底层实现:
// 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
// 2.didSubscribe中，会先订阅第一个源信号（signalA）
// 3.会执行第一个源信号（signalA）的didSubscribe
// 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
// 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
// 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
// 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
- (void)concatSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        MSLog(@"李磊---send1");
        [subscriber sendCompleted];
        return  nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        MSLog(@"李磊---send2");
        [subscriber sendCompleted];
        return nil;
    }];
    
    [[signalA concat:signalB] subscribeNext:^(id x) {
        MSLog(@"李磊---%@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊---%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊---完成");
    }];
}

/*!
 *  @author madis, 16-05-11 11:05:39
 *
 *  zipWith(类似NSArray):把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
 */
// 底层实现:
// 1.定义压缩信号，内部就会自动订阅signalA，signalB
// 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出
- (void)zipWithSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    [[signalA zipWith:signalB] subscribeNext:^(id x) {
        MSLog(@"李磊--- %@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊---%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊---完成");
    }];
}
/*!
 *  @author madis, 16-05-11 11:05:11
 *
 *  then:用于连接两个信号，当第一个信号完成，才会连接then返回的信号。
 */
// 注意使用then，之前信号的值会被忽略掉.
// 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
- (void)thenSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        MSLog(@"李磊----signalA");
        [subscriber sendCompleted];
        return  nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        MSLog(@"李磊----signalB");
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalThen = [signalA then:^RACSignal *{
        return signalB;
    }];
    
    [signalThen subscribeNext:^(id x) {
        MSLog(@"李磊----%@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊----%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊----完成");
    }];
}
/*!
 *  @author madis, 16-05-12 12:05:39
 *
 *  merge:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
 */
// 底层实现：
// 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
// 2.每发出一个信号，这个信号就会被订阅
// 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
// 4.只要有一个信号被发出就会被监听。
- (void)mergeSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        MSLog(@"李磊----signalA");
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@2];
        MSLog(@"李磊----signalB");
        [subscriber sendCompleted];
        return nil;
    }];
    //只要signal中有任何一个改变就会触发subscribeNext操作
    //且只要有signal,sendNext就会有输出,适用于登录注册等动态操作
    [[signalA merge:signalB] subscribeNext:^(id x) {
        MSLog(@"李磊----%@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊----%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊----完成");
    }];
}
/*!
 *  @author madis, 16-05-16 16:05:06
 *
 *  将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号。
 */
// 底层实现：
// 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
// 2.并且把两个信号组合成元组发出。
- (void)combineLatestSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        MSLog(@"李磊----signalA");
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
//        [subscriber sendNext:@2];
        MSLog(@"李磊----signalB");
        [subscriber sendCompleted];
        return nil;
    }];
    //某个signal,sendNext不成功时表示newSignal没combineLatestWith成功,不会subscribeNext消息
    RACSignal *newSignal = [signalA combineLatestWith:signalB];
    [newSignal subscribeNext:^(id x) {
        MSLog(@"李磊----%@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊----%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊----完成");
    }];
    
//    [[RACSignal
//      combineLatest:@[self.priceInput.rac_textSignal,
//                      self.nameInput.rac_textSignal,
//                      RACObserve(self, isConnected)
//                      ]
//      reduce:^(NSString *price, NSString *name, NSNumber *connect){
//          return @(price.length > 0 && name.length > 0 && ![connect boolValue]);
//      }]
//     subscribeNext:^(NSNumber *res){
//         if ([res boolValue]) {
//             NSLog(@"XXXXX send request");
//         }
//     }];
}
/*!
 *  @author madis, 16-05-16 16:05:05
 *
 *  聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
 */
// 底层实现:
// 1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值。
- (void)reduceSignal
{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@1];
        MSLog(@"李磊----signalA");
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *reduceSignal = [RACSignal combineLatest:@[signalA,
                               [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@2];
        MSLog(@"李磊----signalB");
        [subscriber sendCompleted];
        return nil;
    }]] reduce:^id(NSNumber *num1,NSNumber *num2){
        //reduce返回两个signal的sendNext值
        //适用于登陆注册,将usename和password一起合成一个signal传出
        MSLog(@"李磊----signalReduce");
        return [NSString stringWithFormat:@"%@,%@",num1,num2];
    }];
    [reduceSignal subscribeNext:^(id x) {
        MSLog(@"李磊-----%@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊----%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊----完成");
    }];
}
/*!
 *  @author madis, 16-05-16 17:05:01
 *
 *  过滤信号，使用它可以获取满足条件的信号.
 */
// 每次信号发出，会先执行过滤条件判断.
- (void)filterSignal
{
    UITextField *textField = [[UITextField alloc]init];
    [[textField.rac_textSignal filter:^BOOL(id value) {
        return textField.text.length >10;
    }] subscribeNext:^(id x) {
        MSLog(@"李磊-----%@",x);
    } error:^(NSError *error) {
        MSLog(@"李磊----%@",error.localizedDescription);
    } completed:^{
        MSLog(@"李磊----完成");
    }];
    
    //KVC观察input值的变化
//    [[RACObserve(self, input)
//      filter:^(NSString* value){
//          if ([value hasPrefix:@"2"]) {
//              return YES;
//          } else {
//              return NO;
//          }
//      }] subscribeNext:^(NSString* x){
//          request(x);//发送一个请求
//      }];
}
/*!
 *  @author madis, 16-05-16 18:05:59
 *
 *  ignore:忽略完某些值的信号.
 */
// 内部调用filter过滤，忽略掉ignore的值
- (void)ignoreSignal
{
    UITextField *textField = [[UITextField alloc]init];
    [[textField.rac_textSignal ignore:@"1"] subscribeNext:^(id x) {
        MSLog(@"李磊---%@",x);
    }];
    
//    [[RACObserve(self, input) ignore:@"1"] subscribeNext:^(id x) {
//        MSLog(@"李磊---%@",x);
//    }];
}
/*!
 *  @author madis, 16-05-17 10:05:08
 *
 *  当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
 */
// 过滤，当上一次和当前的值不一样，就会发出内容。
// 在开发中，刷新UI经常使用，只有两次数据不一样才需要刷新
- (void)distinctUntilChangedSignal
{
    UITextField *textField = [[UITextField alloc]init];
    [[textField.rac_textSignal distinctUntilChanged] subscribeNext:^(id x) {
        MSLog(@"李磊------%@",x);
    }];

    //???: 难道不好使?
    _input = @111111111;
    [[RACObserve(self, input) distinctUntilChanged] subscribeNext:^(id x) {
        MSLog(@"李磊------%@",x);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
