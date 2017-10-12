//
//  BaseViewModel.m
//  MyWeather
//
//  Created by lijie on 2017/7/28.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "BaseViewModel.h"

@interface BaseViewModel ()

@property (retain,nonatomic) NSMutableArray * requestArray;

@end

@implementation BaseViewModel

- (id)init {
    if (self = [super init]) {
        self.requestArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)registerRequest:(NSURLSessionTask *)sessionTask {
    if (sessionTask != nil) {
        [self.requestArray addObject:sessionTask];
    }
}

- (void)cancelAllHTTPRequest {
    if (self.requestArray != nil && [self.requestArray count] > 0) {
        for (NSInteger i = (NSInteger) ([self.requestArray count] - 1); i>=0; --i) {
            NSURLSessionTask *task = [self.requestArray objectAtIndex:i];
            if (task.state == NSURLSessionTaskStateRunning || task.state == NSURLSessionTaskStateSuspended) {
                [task cancel];
                [self.requestArray removeObject:task];
            }
            else if (task.state == NSURLSessionTaskStateCanceling || task.state == NSURLSessionTaskStateCompleted) {
                [self.requestArray removeObject:task];
            }
        }
    }
}

- (void)dealloc {
    [self cancelAllHTTPRequest];
}


@end
