//
//  LoginViewController.h
//  RACTest
//
//  Created by Madis on 16/5/17.
//
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@end


//1, 成对使用,防止block循环引用
/*@weakify(self);
@strongify(self);
 */
//2,常用的信号处理:(control+T)
//代理方法、block回调、target-action机制、通知、KVO



//RAC怎么忽略首次订阅的signal触发?

