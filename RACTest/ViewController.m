//
//  ViewController.m
//  RACTest
//
//  Created by Madis on 16/5/11.
//
//

#import "ViewController.h"

static NSString *cellIdentifier = @"cell";

@interface ViewController ()
<UITableViewDelegate,
UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) NSArray<NSString *> *cellNameArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _cellNameArray = @[@"concat",@"zipWith",@"then"];
    
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
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
