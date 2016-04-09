//
//  XQOperation.h
//  NSOPDemo
//
//  Created by XQ on 16/3/22.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSOperation+XQExtension.h"

@class XQOperation;

typedef NS_ENUM(NSInteger, XQOperationState) {
    XQOperationPausedState      = -1,
    XQOperationReadyState       = 1,
    XQOperationExecutingState   = 2,
    XQOperationFinishedState    = 3,
    
    XQOperationCancelledState    = -100,
};

typedef void(^XQOperationFinishBlock)(XQOperation *op, id shareDataX, NSError *error);

typedef void(^XQOperationStateChangeBlock)(XQOperation *op, XQOperationState status);

@interface XQOperation : NSOperation

@property (strong, nonatomic) id shareDataX;

@property (copy, nonatomic) XQOperationFinishBlock finishBlockX;

@property (copy, nonatomic) XQOperationStateChangeBlock statusBlockX;



- (instancetype)initWithAsynchronous:(BOOL)asynchronous;

#pragma mark - Hooks

// -------------------------------------------------------------------------------
//  overide this method, should call [self finish] at the end
// -------------------------------------------------------------------------------
- (void)startHook;


// -------------------------------------------------------------------------------
//  if you overide this method,you should process error and call [self finish] at the end
// -------------------------------------------------------------------------------
- (void)cancelHook;

// -------------------------------------------------------------------------------
//  do sth when operation finished
// -------------------------------------------------------------------------------
- (void)finishHook;


#pragma mark - Pause

- (void)pause;

- (void)resume;

- (void)pauseHook;

#pragma mark - Finish

// -------------------------------------------------------------------------------
// Do not override this method.
// -------------------------------------------------------------------------------
- (void)finish;

#pragma mark - Util

- (id)processInLockBlock:(id(^)(void))block;


@end
