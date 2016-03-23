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

#pragma mark - Start

// -------------------------------------------------------------------------------
//  overide this method, should call [self finish] at the end
// -------------------------------------------------------------------------------
- (void)startHook;

#pragma mark - Cancel

// -------------------------------------------------------------------------------
//  if u overide this method,u should process error and call [self finish] at the end
// -------------------------------------------------------------------------------
- (void)cancelHook;


#pragma mark - Pause

- (void)pause;

- (void)resume;

- (void)pauseHook;

#pragma mark - Finish

// -------------------------------------------------------------------------------
//	when you operation did really finish callFinishBlock should be true
//  if cancel, callFinishBlock should be false
// -------------------------------------------------------------------------------
- (void)finish;

#pragma mark - Util

- (id)processInLockBlock:(id(^)(void))block;


@end
