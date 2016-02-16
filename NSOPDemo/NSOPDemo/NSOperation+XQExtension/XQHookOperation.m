//
//  XQHookOperation.m
//  Lunkr
//
//  Created by Bill on 16/2/15.
//  Copyright © 2016年 qxu. All rights reserved.
//

#import "XQHookOperation.h"
#import "NSOperation+XQExtension.h"

@implementation XQHookOperation

- (instancetype)initWithConcurrent:(BOOL)isConcurrent{
    if (self = [super init]) {
        self.isConcurrent_ = @(isConcurrent);
    }
    return self;
}

#pragma mark - 待子类继承

- (void)startHook {
    
}

- (void)cancelHook {
    
}

- (void)start {
    // Always check for cancellation before launching the task.
    if ([self isCancelled]) {
        [self cancel];
        return;
    }
    __weak typeof(self) weakSelf = self;
    [self executingTaskWithBlockXQ:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf startHook];
    }];
    
}

- (BOOL)isConcurrent {
    return [self.isConcurrent_ boolValue];
}

- (BOOL)isExecuting {
    return [self.isExecuting_ boolValue];
}

- (BOOL)isFinished {
    return [self.isFinished_ boolValue];
}

- (BOOL)isCancelled {
    return [self.isCancelled_ boolValue];
}

- (void)cancel {
    [self cancelTaskWithBlockXQ:^{
        [self cancelHook];
        
        [super cancel];
    }];
}

- (void)cancelTaskWithBlockXQ:(void(^)(void))actionBlock  {
    __weak typeof(self) weakSelf = self;
    
    [self changingCancelWithKVOBlockXQ:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isExecuting_ = @(NO);
        strongSelf.isFinished_ = @(YES);
        strongSelf.isCancelled_ = @(YES);
    }];
    
    actionBlock();
}

- (void)executingTaskWithBlockXQ:(void(^)(void))actionBlock {
    __weak typeof(self) weakSelf = self;
    [self changingExecutingKVOBlockXQ:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isExecuting_ = @(YES);
    }];
    actionBlock();
}

- (void)completeTaskForKVOXQ {
    __weak typeof(self) weakSelf = self;
    [self changingCompleteWithKVOBlockXQ:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.isExecuting_ = @(NO);
        strongSelf.isFinished_ = @(YES);
    }];
}

@end
