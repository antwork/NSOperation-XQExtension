//
//  XQOperation.m
//  NSOPDemo
//
//  Created by XQ on 16/3/22.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "XQOperation.h"

static NSString * const kXQNetworkingLockName = @"com.cateatcode.operation.lock";

static inline NSString * XQKeyPathFromOperationState(XQOperationState state) {
    switch (state) {
        case XQOperationReadyState:
            return @"isReady";
        case XQOperationExecutingState:
            return @"isExecuting";
        case XQOperationFinishedState:
            return @"isFinished";
        case XQOperationPausedState:
            return @"isPaused";
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            return @"state";
#pragma clang diagnostic pop
        }
    }
}

static inline BOOL XQStateTransitionIsValid(XQOperationState fromState, XQOperationState toState, BOOL isCancelled) {
    switch (fromState) {
        case XQOperationReadyState:
            switch (toState) {
                case XQOperationPausedState:
                case XQOperationExecutingState:
                    return YES;
                case XQOperationFinishedState:
                    return isCancelled;
                default:
                    return NO;
            }
        case XQOperationExecutingState:
            switch (toState) {
                case XQOperationPausedState:
                case XQOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        case XQOperationFinishedState:
            return NO;
        case XQOperationPausedState:
            return toState == XQOperationReadyState;
        default: {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
            switch (toState) {
                case XQOperationPausedState:
                case XQOperationReadyState:
                case XQOperationExecutingState:
                case XQOperationFinishedState:
                    return YES;
                default:
                    return NO;
            }
        }
#pragma clang diagnostic pop
    }
}

@interface XQOperation()

@property (readwrite, nonatomic, assign) XQOperationState state;

@property (readwrite, nonatomic, strong) NSRecursiveLock *lock;

@property (nonatomic, strong) NSSet *runLoopModes;

@property (assign, nonatomic) BOOL xqAsynchronous;

@end


@implementation XQOperation

- (instancetype)init {
    return nil;
}

- (instancetype)initWithAsynchronous:(BOOL)asynchronous {
    self = [super init];
    if (!self) {
        return nil;
    }
    _state = XQOperationReadyState;
    
    self.xqAsynchronous = asynchronous;
    self.lock = [[NSRecursiveLock alloc] init];
    self.lock.name = kXQNetworkingLockName;
    self.runLoopModes = [NSSet setWithObject:NSRunLoopCommonModes];
    
    return self;
}

#pragma mark - Start

- (void)start {
    [self.lock lock];
    if ([self isCancelled]) {
        [self operationDidCancel];
    } else if ([self isReady]) {
        self.state = XQOperationExecutingState;
        if (self.xqAsynchronous) {
            [self performSelector:@selector(operationDidStart) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        } else {
            [self performSelectorOnMainThread:@selector(operationDidStart) withObject:nil waitUntilDone:NO];
        }
    }
    [self.lock unlock];
}

- (void)operationDidStart {
    [self.lock lock];
    
    [self startHook];
    
    [self.lock unlock];
}

// -------------------------------------------------------------------------------
//  overide this method, should call [self finish] at the end
// -------------------------------------------------------------------------------
- (void)startHook {
    
}

#pragma mark - Cancel

- (void)cancel {
    [self.lock lock];
    if (![self isFinished] && ![self isCancelled]) {
        [super cancel];
        
        if ([self isExecuting]) {
            if (self.xqAsynchronous) {
                [self performSelector:@selector(cancelHook) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
            } else {
                [self performSelectorOnMainThread:@selector(cancelHook) withObject:nil waitUntilDone:NO];
            }
        }
    }
    if (self.statusBlockX) {
        self.statusBlockX(self, XQOperationCancelledState);
    }
    [self.lock unlock];
}

- (void)operationDidCancel {
    if (![self isFinished]) {
        if (self.xqAsynchronous) {
            [self performSelector:@selector(cancelHook) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        } else {
            [self performSelectorOnMainThread:@selector(cancelHook) withObject:nil waitUntilDone:NO];
        }
    }
}

// -------------------------------------------------------------------------------
//  if u overide this method,u should process error and call [self finish] at the end
// -------------------------------------------------------------------------------
- (void)cancelHook {
    NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
    self.errorX = error;
    
    [self finish];
}


#pragma mark - Pause

- (void)pause {
    if ([self isPaused] || [self isFinished] || [self isCancelled]) {
        return;
    }
    
    [self.lock lock];
    if ([self isExecuting]) {
        if (self.xqAsynchronous) {
            [self performSelector:@selector(operationDidPause) onThread:[[self class] networkRequestThread] withObject:nil waitUntilDone:NO modes:[self.runLoopModes allObjects]];
        } else {
            [self performSelectorOnMainThread:@selector(operationDidPause) withObject:nil waitUntilDone:NO];
        }
    }
    
    self.state = XQOperationPausedState;
    [self.lock unlock];
}

- (BOOL)isPaused {
    return self.state == XQOperationPausedState;
}

- (void)resume {
    if (![self isPaused]) {
        return;
    }
    
    [self.lock lock];
    self.state = XQOperationReadyState;
    
    [self start];
    [self.lock unlock];
}

- (void)operationDidPause {
    [self.lock lock];
    [self pauseHook];
    [self.lock unlock];
}

- (void)pauseHook {
    
}

#pragma mark - Finish

// -------------------------------------------------------------------------------
//	when you operation did really finish callFinishBlock should be true
//  if cancel, callFinishBlock should be false
// -------------------------------------------------------------------------------
- (void)finish {
    [self.lock lock];
    self.state = XQOperationFinishedState;
    [self.lock unlock];
    
    if (self.finishBlockX) {
        self.finishBlockX(self, self.shareDataX, self.errorX);
    }
}

#pragma mark - Util

- (id)processInLockBlock:(id(^)(void))block {
    [self.lock lock];
    id result = nil;
    if (block) {
        result = block();
    }
    
    [self.lock unlock];
    return  result;
}

+ (void)networkRequestThreadEntryPoint:(id)__unused object {
    @autoreleasepool {
        [[NSThread currentThread] setName:@"XQOperation"];
        
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

+ (NSThread *)networkRequestThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

#pragma mark - Setter

- (void)setState:(XQOperationState)state {
    if (!XQStateTransitionIsValid(self.state, state, [self isCancelled])) {
        return;
    }
    
    [self.lock lock];
    NSString *oldStateKey = XQKeyPathFromOperationState(self.state);
    NSString *newStateKey = XQKeyPathFromOperationState(state);
    
    [self willChangeValueForKey:newStateKey];
    [self willChangeValueForKey:oldStateKey];
    _state = state;
    [self didChangeValueForKey:oldStateKey];
    [self didChangeValueForKey:newStateKey];
    
    if (self.statusBlockX) {
        self.statusBlockX(self, state);
    }
    
    [self.lock unlock];
}

#pragma mark - Getter

- (BOOL)isReady {
    return self.state == XQOperationReadyState && [super isReady];
}

- (BOOL)isExecuting {
    return self.state == XQOperationExecutingState;
}

- (BOOL)isFinished {
    return self.state == XQOperationFinishedState;
}

- (BOOL)isAsynchronous {
    return self.xqAsynchronous;
}

- (NSRecursiveLock *)lock {
    if (!_lock) {
        _lock = [[NSRecursiveLock alloc] init];
    }
    
    return _lock;
}

@end
