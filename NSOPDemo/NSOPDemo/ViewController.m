//
//  ViewController.m
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "ViewController.h"
#import "NSOperation+XQExtension.h"
#import "XQBlockOP.h"
#import "XQCustomOPDemo.h"

@interface ViewController ()

@property (strong, nonatomic) NSOperationQueue *queue;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = [[NSOperationQueue alloc] init];
    
    XQBlockOP *op1 = [XQBlockOP blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"I'm 1");
    }];
    op1.name = @"op1";
    
    XQBlockOP *op2 = [XQBlockOP blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"I'm 2");
    }];
    op2.name = @"op2";
    [op2 addDependencyXQ:op1];
    XQBlockOP *op3 = [XQBlockOP blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"I'm 3");
    }];
    op3.name = @"op3";
    [op3 addDependencyXQ:op2];
    XQBlockOP *op4 = [XQBlockOP blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"I'm 4");
    }];
    op4.name = @"op4";
    [op4 addDependencyXQ:op3];
    XQBlockOP *op5 = [XQBlockOP blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"I'm 5");
    }];
    op5.name = @"op5";
    [op5 addDependencyXQ:op4];
    XQBlockOP *op6 = [XQBlockOP blockOperationWithBlock:^{
        [NSThread sleepForTimeInterval:1.0];
        NSLog(@"I'm 6");
    }];
    op6.name = @"op6";
    [op6 addDependencyXQ:op5];
    
    [self.queue addOperations:@[op1, op2, op3, op4, op5, op6] waitUntilFinished:false serialName:@"TEST"];
    
//    [op4 cancelXQ];
    
    
//    XQCustomOPDemo *customOP = [[XQCustomOPDemo alloc] initWithConcurrent:false actionBlock:^(XQCustomOperation *operation) {
//        NSLog(@"begin Custom");
//        NSInteger flag = 0;
//        while (flag < 3) {
//            [NSThread sleepForTimeInterval:1];
//            if (operation.isCancelled) {
//                NSLog(@"cancelled");
//                return;
//            }
//            flag++;
//            NSLog(@"next Flag %i", flag);
//        }
//    }];
//    customOP.name = @"Custom OP";
//    [self.queue addOperation:customOP];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.queue cancelSerialOperationsByName:@"TEST"];
    });
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
