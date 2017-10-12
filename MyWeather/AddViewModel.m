//
//  AddViewModel.m
//  MMMemorandum
//
//  Created by lijie on 2017/7/19.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "AddViewModel.h"

/**
 思路：
 1。新建：
 输入事件名，输入完成将事件名赋值给viewmodel的home
 选择日期，选择后将日期赋值给viewmodel的home
 置顶。。
 重复。。
 保存：先判断信息是否完整，必填的为事件名和日期。判断事件名和日期是否为空或者为空字符串即输入内容为空格。如果不为空保存信息。在保存的时候model才有的id，所以判断的时候不能依据id来判断内容是否为空
 
 2。修改：
 将修改后的model，先判断是否完整，比如不小心清空了事件名。如果完整重新保存
 
 3。删除：
 直接将model从本地删除
 */

@implementation AddViewModel

- (instancetype)init {
    if (self = [super init]) {
        _home = [[HomeModel alloc] init];
        _homeListArr = [NSMutableArray array];
    }
    return self;
}

- (void)isCurrentWithData:(HomeModel *)home success:(void (^)(BOOL isCorrect))success failure:(void (^)(NSString *errorString))failure {
    NSDictionary *dic = [self isCurrentResultWithModel:home];
    
    if ([[dic objectForKey:@"result"] isEqualToString:@"no"]) {
        failure([dic objectForKey:@"hint"]);
    } else {
        success(YES);
    }
}

- (NSDictionary *)isCurrentResultWithModel:(HomeModel *)model {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"yes" forKey:@"result"];
    if ([self isEmpty:model.title]) {
        [dic setObject:@"no" forKey:@"result"];
        [dic setObject:NSLocalizedString(@"titlehint", nil) forKey:@"hint"];
        return dic;
    }
    
    if ([self isEmpty:model.date]) {
        [dic setObject:@"no" forKey:@"result"];
        [dic setObject:NSLocalizedString(@"datehint", nil) forKey:@"hint"];
        return dic;
    }
    
    return dic;
}

//保存数据
- (void)saveDataWithModel:(HomeModel *)model success:(void (^)(BOOL result))success failure:(void (^)(NSString *errorString))failure {
    NSLog(@"------");
    //每次保存的时候先将数组置为本地存储的数组，以防每次新建完返回home，再新建的时候，数组已经初始化为nil，所以每次数组都是一个model
    NSString *listFile = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *listPath = [listFile stringByAppendingPathComponent:@"list.plist"];
    self.homeListArr = [NSKeyedUnarchiver unarchiveObjectWithFile:listPath];
    if (self.homeListArr == nil) {
        self.homeListArr = [NSMutableArray new];
    }
    self.home.thingId = self.home.thingId == nil ? [NSDate getNowDateString] : self.home.thingId;
    if (model != nil) {//修改
        NSMutableArray *tmpArr = [NSMutableArray arrayWithArray:self.homeListArr];
        for (HomeModel *hm in tmpArr) {
            if ([hm.thingId isEqualToString:model.thingId]) {
                hm.title = self.home.title==nil?hm.title:self.home.title;
                hm.date = self.home.date==nil?hm.date:self.home.date;
                hm.overdue = self.home.overdue==nil?hm.overdue:self.home.overdue;
                hm.day = self.home.day==nil?hm.day:self.home.day;
                hm.isTop = self.home.isTop;
                hm.repeatType = self.home.repeatType==nil?hm.repeatType:self.home.repeatType;
                self.home = hm;
                if (self.home.isTop) {
                    //设置了置顶，先删除home，再插入到第一个，避免重复
                    [self.homeListArr removeObject:self.home];
                    [self.homeListArr insertObject:self.home atIndex:0];
                }
            }
            [self getTime];
        }
        //将修改了model的数组归档 存到本地
        [NSKeyedArchiver archiveRootObject:self.homeListArr toFile:listPath];
    } else {//新建
        [self getTime];
        //将model存入数组
        if (self.home.isTop) {
            [self.homeListArr insertObject:self.home atIndex:0];
        } else {
            [self.homeListArr addObject:self.home];
        }
        //将添加了model的数组归档 存到本地
        [NSKeyedArchiver archiveRootObject:self.homeListArr toFile:listPath];
    }
    NSLog(@"homelist count -> %ld", self.homeListArr.count);
    NSMutableArray *arr = [NSKeyedUnarchiver unarchiveObjectWithFile:listPath];
    NSLog(@"%@",arr);
    success(YES);
}

//删除数据
- (void)deleteDataWithModel:(HomeModel *)model success:(void (^)(BOOL result))success failure:(void (^)(NSString *errorString))failure {
    NSString *listFile = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *listPath = [listFile stringByAppendingPathComponent:@"list.plist"];
    self.homeListArr = [NSKeyedUnarchiver unarchiveObjectWithFile:listPath];
    NSMutableArray *newArr = [NSMutableArray arrayWithArray:self.homeListArr];
    for (HomeModel *homeM in self.homeListArr) {
        //遍历的时候，被遍历的内容不能被修改，会crash，所以修改新数组
        if ([homeM.thingId isEqualToString:model.thingId]) {
            [newArr removeObject:homeM];
        }
    }
    //将修改后的数组重新归档
    [NSKeyedArchiver archiveRootObject:newArr toFile:listPath];
    success(YES);
}

- (void)getTime {
    //计算时间差
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *dateType = [defaults objectForKey:@"dateType"] == nil ? @"yyyy-MM-dd" : [defaults objectForKey:@"dateType"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateType];//计算的两个时间的时间格式要统一
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    NSDate *date = [formatter dateFromString:self.home.date];
    NSInteger day = [NSDate getDaysFromNowToEnd:date];
    NSString *dayStr = [NSString stringWithFormat:@"%ld", day];
    dayStr = day < 0 ? [dayStr stringByReplacingOccurrencesOfString:@"-" withString:@""] : dayStr;
    self.home.overdue = day < 0 ? @"已过" : @"还有";
    self.home.day = dayStr;
}

//判断内容是否全部为空格 yes 全部为空格 no 不是
- (BOOL)isEmpty:(NSString *)str {
    if(!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        
        if([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}


@end
