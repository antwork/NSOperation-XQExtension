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

#pragma mark - Dependency extension

- (void)addDependencyXQ:(NSOperation *)operation;

- (void)removeDependencyXQ:(NSOperation *)operation;

- (void)cancelXQ;

@end

@interface NSOperationQueue (XQExtension)

@property (nonatomic, strong, readonly) NSMutableDictionary *serialOperationsDictXQ;

- (void)addOperations:(NSArray<NSOperation *> *)ops waitUntilFinished:(BOOL)wait serialName:(NSString *)serialName;

- (void)cancelSerialOperationsByName:(NSString *)serialName;

- (BOOL)isSerialProcessing:(NSString *)serialName;

@end
