//
//  TableViewController.h
//  RACTest
//
//  Created by Madis on 16/5/16.
//
//

#import <UIKit/UIKit.h>
#import "TableViewModel.h"

@interface TableViewControllerCell : UITableViewCell
@property (nonatomic,strong) UserModel *model;
//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier mode:(UserModel *)model;
@end

@interface TableViewController : UITableViewController

@end


//skip,跳过第一个
//尽量是一个signal管道处理一个操作,尽量解耦,以便扩展