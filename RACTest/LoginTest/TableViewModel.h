//
//  TableViewModel.h
//  RACTest
//
//  Created by Madis on 16/5/31.
//
//

#import <Foundation/Foundation.h>

typedef  NS_ENUM(NSInteger, UserSex) {
    UserSex_unKnown = 0,
    UserSex_male    = 1,
    UserSex_female  = 2
};

@interface UserModel : NSObject
@property (nonatomic,copy  ) NSString  *name;
@property (nonatomic,assign) NSInteger uid;
@property (nonatomic,copy  ) NSString  *introduction;
@property (nonatomic,assign) UserSex   sex;
-(instancetype)initWithName:(NSString*)name;
@end
@interface TableViewModel : NSObject
@property (nonatomic, strong) NSMutableArray <UserModel *>*allDataArray;
//演示用
@property (nonatomic, strong) NSMutableArray <UserModel *>*topDataArray;
@property (nonatomic, strong) NSMutableArray <UserModel *>*normalDataArray;

- (void)loadUsers;

@end
//数组元素的监听
