//
//  NSOperation+XQExtension.h
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperation (XQExtension)

@property (nonatomic, strong, readonly) NSMutableArray *dependenciesXQ;

@property (nonatomic, strong) NSNumber *isExecuting_;

@property (nonatomic, strong) NSNumber *isFinished_;

@property (nonatomic, strong) NSNumber *isCancelled_;

@property (nonatomic, strong) NSNumber *isConcurrent_;

#pragma mark - Dependency extension

- (void)addDependencyXQ:(NSOperation *)operation;

- (void)removeDependencyXQ:(NSOperation *)operation;

- (void)cancelXQ;

#pragma mark - Custom NSOperation extension

// you can handle the status in block and this method will handle kvo change for you
- (void)changingExecutingKVOBlockXQ:(void(^)(void))block;

// you can handle the status in block and this method will handle kvo change for you
- (void)changingCompleteWithKVOBlockXQ:(void(^)(void))block;

// you can handle the status in block and this method will handle kvo change for you
- (void)changingCancelWithKVOBlockXQ:(void(^)(void))block;

@end

@interface NSOperationQueue (XQExtension)

@property (nonatomic, strong, readonly) NSMutableDictionary *serialOperationsDictXQ;

- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait serialName:(NSString *)serialName;

- (void)cancelSerialOperationsByName:(NSString *)serialName;

- (BOOL)isSerialProcessing:(NSString *)serialName;

@end
