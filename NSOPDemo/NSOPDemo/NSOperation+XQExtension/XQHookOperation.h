//
//  XQHookOperation.h
//  Lunkr
//
//  Created by Bill on 16/2/15.
//  Copyright © 2016年 qxu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XQHookOperation : NSOperation

- (instancetype)initWithConcurrent:(BOOL)isConcurrent;

#pragma mark - 待子类继承

// 开始的钩子方法
- (void)startHook;

// 取消的钩子方法
- (void)cancelHook;

// 任务完成调用
- (void)completeTaskForKVOXQ;

@end
