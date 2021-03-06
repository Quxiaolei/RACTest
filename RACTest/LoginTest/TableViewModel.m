//
//  TableViewModel.m
//  RACTest
//
//  Created by Madis on 16/5/31.
//
//

#import "TableViewModel.h"

@implementation UserModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(instancetype)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        self.name = name;
        self.uid = arc4random()% 9;
        self.introduction = [NSString stringWithFormat:@"这就是%@的简介-%u",name,arc4random()% 9];
        self.sex = arc4random()% 3;
    }
    return self;
}
@end
@implementation TableViewModel

- (id)init
{
    self = [super init];
    if(self){
        self.allDataArray    = [NSMutableArray arrayWithCapacity:0];
        self.topDataArray    = [NSMutableArray arrayWithCapacity:0];
        self.normalDataArray = [NSMutableArray arrayWithCapacity:0];
        
        [self initSignal];
    }
    return self;
}
//初始化signal
- (void)initSignal
{
    RACSubject *subject_setting     = [RACSubject new];
    RACSubject *subject_insertion   = [RACSubject new];
    RACSubject *subject_removal     = [RACSubject new];
    RACSubject *subject_replacement = [RACSubject new];
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew;
//    [self rac_valuesForKeyPath:@keypath(self.allDataArray)  observer:self];
    [[self rac_valuesAndChangesForKeyPath:@keypath(self.allDataArray)
                                  options:options
                                 observer:self]
     subscribeNext:^(id x) {
         RACTupleUnpack(id sub, NSDictionary *changeDict) = x;
         NSInteger kind = [[changeDict valueForKey:NSKeyValueChangeKindKey] integerValue];
         id oldValue    = [changeDict valueForKey:NSKeyValueChangeOldKey];
         id newValue    = [changeDict valueForKey:NSKeyValueChangeNewKey];
         id index       = [changeDict valueForKey:NSKeyValueChangeIndexesKey];
         switch (kind) {
             case NSKeyValueChangeSetting: [subject_setting sendNext:newValue]; break;
             case NSKeyValueChangeInsertion: [subject_insertion sendNext:newValue]; break;
             case NSKeyValueChangeRemoval: [subject_removal sendNext:oldValue]; break;
             case NSKeyValueChangeReplacement: [subject_replacement sendNext:RACTuplePack(newValue,oldValue)]; break;
             default:
                 break;
         }
    }];
    @weakify(self);
    //初始化数组
    [subject_setting subscribeNext:^(NSArray *x) {
        @strongify(self);
        for (UserModel *user in x) {
            if (UserSex_male == user.sex){
                [[self mutableArrayValueForKey:@"topDataArray"] addObject:user];
            }else if (UserSex_female == user.sex){
                [[self mutableArrayValueForKey:@"normalDataArray"] addObject:user];
            }
        }
    }];
    //数组插入对象
    [subject_insertion subscribeNext:^(NSArray *x) {
        @strongify(self);
        UserModel *user = [x firstObject];
        if (UserSex_male == user.sex){
            [[self mutableArrayValueForKey:@"topDataArray"] addObject:user];
        }else if (UserSex_female == user.sex){
            [[self mutableArrayValueForKey:@"normalDataArray"] addObject:user];
        }
    }];
    //数组删除对象
    [subject_removal subscribeNext:^(NSArray *x) {
        @strongify(self);
        UserModel *user = [x firstObject];
        if (UserSex_male == user.sex){
            [[self mutableArrayValueForKey:@"topDataArray"] removeObject:user];
        }else if (UserSex_female == user.sex){
            [[self mutableArrayValueForKey:@"normalDataArray"] removeObject:user];
        }
    }];
    //数组替换对象
    [subject_replacement subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(NSArray *user_oldArray, NSArray *user_newArray) = x;
        UserModel *user_old = [user_oldArray firstObject];
        UserModel *user_new = [user_newArray firstObject];
        //!!!: 待完善
    }];
}
- (void)loadUsers
{
    NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:0];
    for(int i= 0;i<20;i++){
        UserModel *user = [[UserModel alloc] initWithName:[NSString stringWithFormat:@"张三-%d号",i]];
        //!!!:插入方法呢?
//        [self.allDataArray addObject:user];
        [mutableArray addObject:user];
    }
    self.allDataArray = mutableArray;
}
@end
