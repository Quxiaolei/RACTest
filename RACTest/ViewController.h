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
 *  热/冷signal,signal中存有数据类型
 *  算符:什么时候subscribe
 */

//ReactiveCocoa 主要由以下四大核心组件构成：
//* 信号源：RACStream/RACSignal/RACSubject/RACSequence 及其子类；
//* 订阅者：RACSubscriber/RACMulticastConnection 的实现类及其子类；
//* 调度器：RACScheduler 及其子类；
//* 清洁工：RACDisposable 及其子类。

#pragma mark - RACCommand
//RACCommand:一般用于表示某个Action的执行，比如点击Button。它有几个比较重要的属性：executionSignals / errors / executing。
//1、executionSignals是signal of signals，如果直接subscribe的话会得到一个signal，而不是我们想要的value，所以一般会配合switchToLatest。
//2、errors。跟正常的signal不一样，RACCommand的错误不是通过sendError来实现的，而是通过errors属性传递出来的。
//3、executing表示该command当前是否正在执行。
//RACSignal *imageAvailableSignal = [RACObserve(self, imageView.image) map:id^(id x){return x ? @YES : @NO}];
//self.shareButton.rac_command = [[RACCommand alloc] initWithEnabled:imageAvailableSignal signalBlock:^RACSignal *(id input) {
//    // do share logic
//}];

#pragma mark - RACSubject
//RACSubject:手动创建的类似于RACSignal的signal,可以有send next,error,completed
//RACSubject *subject_newSubject = [RACSubject subject];

#pragma mark - RACTuple
//RACTuple:signal数组,存在first,last,second等方法

#pragma mark - RACSignal
//error:整个通道都出现问题,不能订阅,用catch捕获到error signal(一般为了使通道可用,在catch的block中返回[RACSignal empty])
//[RACSignal empty]:signal很快就会完成,sendCompleted,一般用于catch操作中,确保通道不断
//[RACSignal repeat]:signal完成后,重新subscribe
//[RACSignal doNext]:在某个signal到来的时候做某个操作,跟signal无关

//timeout:onScheduler:网络超时,在等待了某个interval后仍没有返回,发送error
//delay:在延迟了某个interval后执行sendNext和sendCompleted操作

#pragma mark - RACStream
//[RACStream take:1]:取出该stream中的第一个值加上completed,作为一个signal
//[RACStream skip:1]:扔掉该stream中的第一个值将剩余的值加一个completed,作为一个signal

//FIXME: flatten和flattenMap的区别
//flatten:返回streams中的stream(Merge)
//flattenMap:在block回调中需要一个RACStream的返回值(SelectMany),多用于网络请求和回调的处理.
//           多个flattenMap连续使用通常用于做连续的操作,如果需要从上一级传递参数,试试map


#pragma mark - RACDisposable

//[RACDisposable disposableWithBlock:^{}];  一般在block中做些取消操作
//dispose:直接signal的订阅

#pragma mark - 线程操作符
//doNext/doError(类比catch)/doCompleted/finally(不论error还是completed都会调用)
//delay:在send next和completed之前延迟()s
//repeat:signal完成后再重复订阅




//网络请求后的操作和UI的操作,一般要在主线程上[ deliverOnMainThread]


