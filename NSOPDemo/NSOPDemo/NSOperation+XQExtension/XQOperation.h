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

@property (strong, nonatomic) NSError *errorX;

@property (copy, nonatomic) XQOperationFinishBlock finishBlockX;

@property (copy, nonatomic) XQOperationStateChangeBlock statusBlockX;

- (instancetype)initWithAsynchronous:(BOOL)asynchronous;

// start method hook, will executing when start
- (void)startHook;

// cacel method hook , will executing when cancel
- (void)cancelHook;

#pragma mark - Pause

- (void)pause;

- (BOOL)isPaused;

- (void)resume;

// finish when task done
- (void)finish;

// do sth in lock
- (id)processInLockBlock:(id(^)(void))block;

@end
