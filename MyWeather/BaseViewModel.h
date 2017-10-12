//
//  BaseViewModel.h
//  MyWeather
//
//  Created by lijie on 2017/7/28.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseViewModel : NSObject

- (void)registerRequest:(NSURLSessionTask *)sessionTask;
- (void)cancelAllHTTPRequest;

@end
