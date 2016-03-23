//
//  XQStep2ProcessWeatherOp.m
//  NSOPDemo
//
//  Created by XQ on 16/3/23.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "XQStep2ProcessWeatherOp.h"
#import "XQShareModel.h"

@implementation XQStep2ProcessWeatherOp

- (void)dealloc {
    NSLog(@"dealloc %@", self.name);
}

- (void)startHook {
    XQShareModel *model = self.shareDataX;
    NSDictionary *json = model.weatherInfo;
    
    if (!json) {
        [self cancelXQ];
    }
    
    sleep(3);
    NSLog(@"weather %@", json);
    NSLog(@"step1 begin");
    NSString *errMsg = json[@"errMsg"];
    if ([errMsg isEqualToString:@"success"]) {
        NSArray *retData = json[@"retData"];
        for (NSDictionary *dict in retData) {
            NSString *area_Id = dict[@"area_id"];
            if ([area_Id integerValue] == 101010300) {
                model.result = dict[@"name_cn"];
                break;
            }
        }
    } else {
        self.errorX = [NSError errorWithDomain:@"" code:0 userInfo:nil];
    }
    
    [self finish];
    
}

@end
