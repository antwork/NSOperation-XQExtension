//
//  FailOperation.m
//  NSOPDemo
//
//  Created by Lunkr on 16/4/8.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "FailOperation.h"

@implementation FailOperation

- (void)startHook {
    NSLog(@"start %@", self.name);
    sleep(1);
    
    self.errorX = [NSError errorWithDomain:@"xx" code:1 userInfo:nil];
    
    [self finish];
}

- (void)finishHook {
    NSLog(@"finish:%@ error:%@", self.name, self.errorX);
}

@end
