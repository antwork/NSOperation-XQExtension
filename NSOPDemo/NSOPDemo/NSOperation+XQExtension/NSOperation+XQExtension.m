//
//  NSOperation+XQExtension.m
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "NSOperation+XQExtension.h"
#import <objc/runtime.h>

static char dependenciesXQChar;

static char serialOperationsXQChar;

static char isExecutingXQChar;

static char isFinishedXQChar;

static char isCancelledXQChar;

static char isConcurrentXQChar;

@implementation NSOperation (XQExtension)

@dynamic dependenciesXQ;

@dynamic isConcurrent_;

@dynamic isExecuting_;

@dynamic isCancelled_;

@dynamic isFinished_;

#pragma mark - Dependency extension

- (void)addDependencyXQ:(NSOperation *)operation {
    if (!operation) {
        return;
    }
    
    if (!operation.dependenciesXQ) {
        operation.dependenciesXQ = [NSMutableArray array];
    }
    
    // can't add self to target array directly, it will cause dead circle
    // so use non retain obj to avoid it
    NSValue *value = [NSValue valueWithNonretainedObject:self];
    [operation.dependenciesXQ addObject:value];
    
    [self addDependency:operation];
}

- (void)removeDependencyXQ:(NSOperation *)operation {
    if (!operation) {
        return;
    }
    
    [operation.dependenciesXQ removeObject:self];
    
    [self removeDependency:operation];
}

- (void)cancelXQ {
    [self cancel];
    NSLog(@"cancelXQ %@", self.name);
    for (NSValue *value in self.dependenciesXQ) {
        NSOperation *op = [value nonretainedObjectValue];
        [op cancelXQ];
    }
}

#pragma mark - Custom NSOperation extension

- (void)changingExecutingKVOBlockXQ:(void(^)(void))block {
    [self willChangeValueForKey:@"isExecuting"];
    if (block) {
        block();
    }
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)changingCompleteWithKVOBlockXQ:(void(^)(void))block {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    if (block) {
        block();
    }
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)changingCancelWithKVOBlockXQ:(void(^)(void))block {
    [self willChangeValueForKey:@"isCancelled"];
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    if (block) {
        block();
    }
    
    [self didChangeValueForKey:@"isCancelled"];
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - Setter

- (void)setDependenciesXQ:(NSMutableArray *)dependenciesXQ {
    objc_setAssociatedObject(self, &dependenciesXQChar, dependenciesXQ, OBJC_ASSOCIATION_RETAIN);
}

- (void)setIsExecuting_:(NSNumber *)isExecuting_ {
    objc_setAssociatedObject(self, &isExecutingXQChar, isExecuting_, OBJC_ASSOCIATION_RETAIN);
}

- (void)setIsFinished_:(NSNumber *)isFinished_ {
    objc_setAssociatedObject(self, &isFinishedXQChar, isFinished_, OBJC_ASSOCIATION_RETAIN);
}

- (void)setIsConcurrent_:(NSNumber *)isConcurrent_ {
    objc_setAssociatedObject(self, &isConcurrentXQChar, isConcurrent_, OBJC_ASSOCIATION_RETAIN);
}

- (void)setIsCancelled_:(NSNumber *)isCancelled_ {
    objc_setAssociatedObject(self, &isCancelledXQChar, isCancelled_, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark - Getter

- (NSMutableArray *)dependenciesXQ {
    return objc_getAssociatedObject(self, &dependenciesXQChar);
}

- (NSNumber *)isExecuting_ {
    return objc_getAssociatedObject(self, &isExecutingXQChar);
}

- (NSNumber *)isFinished_ {
    return objc_getAssociatedObject(self, &isFinishedXQChar);
}

- (NSNumber *)isConcurrent_ {
    return objc_getAssociatedObject(self, &isConcurrentXQChar);
}

- (NSNumber *)isCancelled_ {
    return objc_getAssociatedObject(self, &isCancelledXQChar);
}

@end




@implementation NSOperationQueue (XQExtension)

@dynamic serialOperationsDictXQ;

- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait serialName:(NSString *)serialName {
    if (ops.count > 0 && serialName) {
        if (!self.serialOperationsDictXQ) {
            self.serialOperationsDictXQ = [NSMutableDictionary dictionary];
        }
        
        [self.serialOperationsDictXQ setObject:ops forKey:serialName];
    }
    
    [self addOperations:ops waitUntilFinished:wait];
}

- (void)cancelSerialOperationsByName:(NSString *)serialName {
    if (serialName) {
        NSArray *operations = [self.serialOperationsDictXQ objectForKey:serialName];
        
        for (NSOperation *op in operations) {
            if ([op isExecuting] ) {
                [op cancelXQ];
                break;
            }
        }
        
        [self.serialOperationsDictXQ removeObjectForKey:serialName];
    }
}

- (void)setSerialOperationsDictXQ:(NSMutableDictionary *)serialOperationsDictXQ {
    objc_setAssociatedObject(self, &serialOperationsXQChar, serialOperationsDictXQ, OBJC_ASSOCIATION_RETAIN);
}

- (NSNumber *)serialOperationsDictXQ {
    return objc_getAssociatedObject(self, &serialOperationsXQChar);
}

- (BOOL)isSerialProcessing:(NSString *)serialName {
    if (serialName) {
        NSArray *operations = [self.serialOperationsDictXQ objectForKey:serialName];
        
        for (NSOperation *op in operations) {
            BOOL isNotFinishOrCancel = ![op isCancelled] && ![op isFinished];
            if (isNotFinishOrCancel) {
                return YES;
            }
        }
    }
    
    return NO;
}

@end