//
//  NSOperation+XQExtension.m
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "NSOperation+XQExtension.h"
#import <objc/runtime.h>

static char dependsOnSelfOpsXQChar;

static char serialOperationsXQChar;

static char errorXChar;

@implementation NSOperation (XQExtension)

@dynamic dependsOnSelfOpsXQ;

#pragma mark - Dependency extension

- (void)addDependencyXQ:(NSOperation *)operation {
    if (!operation) {
        return;
    }
    
    if (!operation.dependsOnSelfOpsXQ) {
        operation.dependsOnSelfOpsXQ = [NSMutableArray array];
    }
    
    // can't add self to target array directly, it will cause dead circle
    // so use non retain obj to avoid it
    NSValue *value = [NSValue valueWithNonretainedObject:self];
    [operation.dependsOnSelfOpsXQ addObject:value];
    
    [self addDependency:operation];
}

- (void)removeDependencyXQ:(NSOperation *)operation {
    if (!operation) {
        return;
    }
    
    [operation.dependsOnSelfOpsXQ removeObject:self];
    
    [self removeDependency:operation];
}

- (void)cancelXQ {
#ifdef DEBUG
    NSLog(@"cancelXQ %@", self.name);
#endif
    for (NSValue *value in self.dependsOnSelfOpsXQ) {
        NSOperation *op = [value nonretainedObjectValue];
        [op cancelXQ];
    }
    
    [self cancel];
}

// -------------------------------------------------------------------------------
//  errorX != nil -> fail
// -------------------------------------------------------------------------------
- (BOOL)isFailureXQ {
    return self.errorX != nil;
}

- (NSArray *)getDependsOnSelfOps {
    NSMutableArray *values = [NSMutableArray array];
    for (NSValue *value in self.dependsOnSelfOpsXQ) {
        NSOperation *op = [value nonretainedObjectValue];
        if (op) {
            [values addObject:op];
        }
    }
    if (values.count > 0) {
        return values;
    } else {
        return nil;
    }
}


#pragma mark - Setter

- (void)setDependsOnSelfOpsXQ:(NSMutableArray *)dependsOnSelfOpsXQ {
    objc_setAssociatedObject(self, &dependsOnSelfOpsXQChar, dependsOnSelfOpsXQ, OBJC_ASSOCIATION_RETAIN);
}



- (void)setErrorX:(NSError *)errorX {
    objc_setAssociatedObject(self, &errorXChar, errorX, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Getter

- (NSMutableArray *)dependsOnSelfOpsXQ {
    return objc_getAssociatedObject(self, &dependsOnSelfOpsXQChar);
}

- (NSError *)errorX {
    return objc_getAssociatedObject(self, &errorXChar);
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
            [op cancel];
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