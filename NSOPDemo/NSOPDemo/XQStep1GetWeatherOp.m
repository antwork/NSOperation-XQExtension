//
//  XQStep1GetWeatherOp.m
//  NSOPDemo
//
//  Created by XQ on 16/3/23.
//  Copyright © 2016年 XQ. All rights reserved.
//

#import "XQStep1GetWeatherOp.h"

#define BASE_URL @"http://www.weather.com.cn/data/sk/"

@interface XQStep1GetWeatherOp() <NSURLConnectionDelegate>

@end


@implementation XQStep1GetWeatherOp

- (void)dealloc {
    NSLog(@"dealloc %@", self.name);
}

- (void)startHook {
    sleep(3);
    NSString *httpUrl = @"http://apis.baidu.com/apistore/weatherservice/citylist";
    NSString *httpArg = @"cityname=%E6%9C%9D%E9%98%B3";
    
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, httpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"您自己的apikey" forHTTPHeaderField: @"apikey"];
    
    __weak typeof(self) weakSelf = self;
    NSLog(@"step1 begin");
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               __strong typeof(weakSelf) strongSelf = weakSelf;
                               if (error) {
                                   strongSelf.errorX = error;
                                   [strongSelf finish];
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"HttpResponseCode:%ld", responseCode);
                                   NSLog(@"HttpResponseBody %@",responseString);
                                   XQShareModel *model = strongSelf.shareDataX;
                                   NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                   model.weatherInfo = json;
                                   strongSelf.errorX = error;
                                   
                                   [strongSelf finish];
                               }
                           }];
}

//
//#pragma  mark -
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
//    [self.data appendData:data];
//}
//
//- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
//    if (self.shareDataX) {
//        XQShareModel *model = self.shareDataX;
//        NSError *error;
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingMutableLeaves error:&error];
//        model.weatherInfo = json;
//        self.errorX = error;
//    }
//    
//    [self finish];
//}
//
//- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
//    NSLog(@"出错信息 = %@",error);
//    self.errorX = error;
//    
//    [self finish];
//}

@end
