//
//  NSOperation+XQExtension.h
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ENUM(NSInteger) {
    XQErrorCodeShareDataNotSatisfied = 8709001,
};

@interface NSOperation (XQExtension)

@property (nonatomic, strong, readonly) NSMutableArray *dependsOnSelfOpsXQ;

// -------------------------------------------------------------------------------
//  mark operation failure error
// -------------------------------------------------------------------------------
@property (strong, nonatomic) NSError *errorX;

#pragma mark - Dependency extension

- (void)addDependencyXQ:(NSOperation *)operation;

- (void)removeDependencyXQ:(NSOperation *)operation;

#pragma mark - Utils

- (void)cancelXQ;

// -------------------------------------------------------------------------------
//  errorX != nil -> fail
// -------------------------------------------------------------------------------
- (BOOL)isFailureXQ;

- (NSArray *)getDependsOnSelfOps;

@end

@interface NSOperationQueue (XQExtension)

@property (nonatomic, strong, readonly) NSMutableDictionary *serialOperationsDictXQ;

- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait serialName:(NSString *)serialName;

- (void)cancelSerialOperationsByName:(NSString *)serialName;

- (BOOL)isSerialProcessing:(NSString *)serialName;

@end

extern NSString * const XQOperationErrorMessageKey;
