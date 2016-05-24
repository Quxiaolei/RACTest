//
//  TableViewController.m
//  RACTest
//
//  Created by Madis on 16/5/16.
//
//

#import "TableViewController.h"

@interface TableViewController ()
@property (nonatomic,strong) NSArray<NSString *> *cellNameArray;

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    _cellNameArray = [[NSArray alloc]initWithObjects:@"131",@"11421414",@"1",@"13144", nil];
    
    self.navigationItem.title = @"tableView";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"获取数据" style:UIBarButtonItemStylePlain target:nil action:nil];
    @weakify(self);
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(UIBarButtonItem *input) {
        MSLog(@"李磊---------%@",input);
        RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            [subscriber sendNext:input];
            [subscriber sendCompleted];
            return nil;
        }];
        @strongify(self);
        [self getDataSource];
        return signal;
    }];
}


- (void)getDataSource
{
//    ACSequence 代表的是一个不可变的值的序列，与 RACSignal 不同，它是 pull-driven 类型的流，不可以被订阅者订阅，但是它与 RACSignal之间可以非常方便地进行转换。
//    从理论上说，一个 RACSequence 由两部分组成：
//    head ：指的是序列中的第一个对象，如果序列为空，则为 nil ；
//    tail ：指的是序列中除第一个对象外的其它所有对象，同样的，如果序列为空，则为 nil。(tail又是一个RACSequence)

    //类似于For-In遍历,直到找到第一个满足条件的数据
//    RACSequence *results = [[_cellNameArray.rac_sequence filter:^ BOOL (NSString *str) {
//        MSLog(@"李磊---fiter-%@",str);
//        return str.length >= 4;
//    }] map:^(NSString *str) {
//        MSLog(@"李磊---map-%@",str);
//        return str;
//    }];
//    NSString *str = results.head;
//    MSLog(@"李磊---result-%@",str);
    
    //For-In遍历,查询所有满足条件的数据
    [[_cellNameArray.rac_sequence filter:^BOOL(NSString *value) {
        return value.length >3;
    }] all:^BOOL(NSString *value) {
        MSLog(@"李磊----%@",value);
        return YES;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
