//
//  XQCocurrentOperation.m
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "XQBlockOperation.h"
#import "NSOperation+XQExtension.h"

@interface XQBlockOperation ()

@property (strong, nonatomic) void(^actionBlock_)(XQBlockOperation *operation);

@end


@implementation XQBlockOperation

- (instancetype)initWithConcurrent:(BOOL)isConcurrent
                       actionBlock:(void(^)(XQBlockOperation *operation))actionBlock {
    if (self = [super init]) {
        self.isConcurrent_ = @(isConcurrent);
        self.actionBlock_ = actionBlock;
    }
    return self;
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
        strongSelf.actionBlock_(strongSelf);

        [strongSelf completeTaskForKVOXQ];
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
