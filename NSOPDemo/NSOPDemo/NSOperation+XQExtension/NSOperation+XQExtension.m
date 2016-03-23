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

@implementation NSOperation (XQExtension)

@dynamic dependenciesXQ;


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
    NSLog(@"cancelXQ %@", self.name);
    for (NSValue *value in self.dependenciesXQ) {
        NSOperation *op = [value nonretainedObjectValue];
        [op cancelXQ];
    }
    
    [self cancel];
}


#pragma mark - Setter

- (void)setDependenciesXQ:(NSMutableArray *)dependenciesXQ {
    objc_setAssociatedObject(self, &dependenciesXQChar, dependenciesXQ, OBJC_ASSOCIATION_RETAIN);
}


#pragma mark - Getter

- (NSMutableArray *)dependenciesXQ {
    return objc_getAssociatedObject(self, &dependenciesXQChar);
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