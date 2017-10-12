//
//  HeaderView.m
//  MMMemorandum
//
//  Created by lijie on 2017/7/18.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "HeaderView.h"

@interface HeaderView ()

@property (weak, nonatomic) IBOutlet UILabel *overdueLab;//已过/还有
@property (weak, nonatomic) IBOutlet UILabel *titleLab;//标题
@property (weak, nonatomic) IBOutlet UILabel *dateLab;//日期
@property (weak, nonatomic) IBOutlet UILabel *dLab;//天
@property (weak, nonatomic) IBOutlet UILabel *weatherLab;//天气
@property (weak, nonatomic) IBOutlet UILabel *wenduLab;//温度
@property (weak, nonatomic) IBOutlet UILabel *windLab;//风向
@property (weak, nonatomic) IBOutlet UILabel *locationLab;//位置

@end

@implementation HeaderView

- (void)setDataWithModel:(HomeModel *)model {
    self.overdueLab.text = model.overdue == nil ? NSLocalizedString(@"nodata", nil): model.overdue;
    self.dayLab.text = model.day;
    self.titleLab.text = model.title;
    self.dateLab.text = model.date;
    self.dLab.text = model == nil ? @"" : NSLocalizedString(@"day", nil);
}

- (void)getWeatherWithModel:(Now *)model localCity:(NSString *)city {
    if (model) {
        self.weatherLab.text = model.cond.txt;
        self.wenduLab.text = [model.tmp stringByAppendingString:@"°"];
        self.windLab.text = [NSString stringWithFormat:@"%@", model.wind.dir];
    }
    self.locationLab.text = @"Shanghai";
}

@end
