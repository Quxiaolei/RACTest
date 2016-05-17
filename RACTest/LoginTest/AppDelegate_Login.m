//
//  AppDelegate_Login.m
//  RACTest
//
//  Created by Madis on 16/5/17.
//
//

#import "AppDelegate_Login.h"
#import "LoginViewController.h"

@implementation AppDelegate_Login

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    //    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    
    LoginViewController *loginVC = [[LoginViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginVC];
    self.window.rootViewController = nav;
    
    return YES;
}
@end
