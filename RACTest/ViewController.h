//
//  ViewController.h
//  RACTest
//
//  Created by Madis on 16/5/11.
//
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController


@end


/*!
 *  @author madis, 16-05-25 22:05:27
 *
 *  核心思想:在subscribe之前将所有signal全部处理完成
 *  每个signal对应一种操作,不管是操作数据,操作view,还是请求网络
 */

//ReactiveCocoa 主要由以下四大核心组件构成：
//* 信号源：RACStream/RACSignal/RACSubject/RACSequence 及其子类；
//* 订阅者：RACSubscriber/RACMulticastConnection 的实现类及其子类；
//* 调度器：RACScheduler 及其子类；
//* 清洁工：RACDisposable 及其子类。


//RACTuple:signal数组,存在first,last,second等方法

//error:整个通道都出现问题,不能订阅
//[RACSignal empty]:signal很快就会完成,sendCompleted
//[RACSignal repeat]:signal完成后,重新subscribe


//[RACStream take:1]:取该signal的第一个值






