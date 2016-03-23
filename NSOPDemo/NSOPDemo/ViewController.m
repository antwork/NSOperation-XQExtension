//
//  ViewController.m
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "ViewController.h"
#import "NSOperation+XQExtension.h"
#import "XQOperation.h"
#import "XQStep1GetWeatherOp.h"
#import "XQStep2ProcessWeatherOp.h"

@interface ViewController ()

@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)doSth {
    XQShareModel *model = [[XQShareModel alloc] init];
    
    XQStep1GetWeatherOp *op1 = [[XQStep1GetWeatherOp alloc] initWithAsynchronous:YES];
    op1.shareDataX = model;
    op1.name = @"step1";
    
    XQStep2ProcessWeatherOp *op2 = [[XQStep2ProcessWeatherOp alloc] initWithAsynchronous:YES];
    [op2 setFinishBlockX:^(XQOperation *op, id resultData, NSError *error){
        XQShareModel *model = op.shareDataX;
        if (error) {
            NSLog(@"\n\nerror %@", error);
        } else {
            NSLog(@"\n\nfinish %@", model.result);
        }
        
    }];
    op2.name = @"step2";
    [op2 setStatusBlockX:^(XQOperation *op, XQOperationState state) {
        NSLog(@"op:%@ state:%i", op.name, state);
    }];
    op2.shareDataX = model;
    
    [op2 addDependencyXQ:op1];
    [self.queue addOperations:@[op1,op2] waitUntilFinished:NO serialName:@"GetWeather"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.queue cancelSerialOperationsByName:@"GetWeather"];
    });

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    
    // 测试cancel会不会自动从Queue里移除, 答案是会
    NSOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op1 begin");
        sleep(3);
        NSLog(@"op1 end");
    }];
    
    NSOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"op2 begin");
        sleep(3);
        NSLog(@"op2 end");
    }];

    [self.queue addOperation:op1];
    [self.queue addOperation:op2];
    
    NSArray *ops = [self.queue operations];
    NSLog(@"ops %@", ops);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [op1 cancel];
        [op2 cancel];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *ops = [self.queue operations];
        NSLog(@"===1 ops %@", ops);
    });
    

//    // 测试cancel会不会自动从Queue里移除,
//    XQShareModel *model = [[XQShareModel alloc] init];
//    XQStep1GetWeatherOp *op3 = [[XQStep1GetWeatherOp alloc] initWithAsynchronous:YES];
//    op3.shareDataX = model;
//    op3.name = @"step1";
//    
//    NSOperation *op4 = [NSBlockOperation blockOperationWithBlock:^{
//        NSLog(@"op4 begin");
//        sleep(3);
//        NSLog(@"op4 end");
//    }];
//    [op4 addDependencyXQ:op3];
//    [self.queue addOperation:op4];
//    [self.queue addOperation:op4];
//    
//    ops = [self.queue operations];
//    NSLog(@"ops %@", ops);
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [op1 cancelXQ];
//    });
//    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSArray *ops = [self.queue operations];
//        NSLog(@"====2 ops %@", ops);
//    });
//    
//    //    [self.queue addOperation:op2];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doSth];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doSth];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doSth];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self doSth];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSArray *ops = [self.queue operations];
            NSLog(@"ops %@", ops);
        });
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
