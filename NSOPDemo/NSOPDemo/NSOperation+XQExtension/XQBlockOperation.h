//
//  XQCocurrentOperation.h
//  NSOPDemo
//
//  Created by Bill on 16/1/30.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XQBlockOperation : NSOperation

- (instancetype)initWithConcurrent:(BOOL)isConcurrent
                       actionBlock:(void(^)(XQBlockOperation *operation))actionBlock;

@end
