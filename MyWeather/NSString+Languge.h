//
//  NSString+Languge.h
//  MyWeather
//
//  Created by lijie on 2017/8/3.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Languge)

//当前语言是中文还是英文
+ (BOOL)currentLanguageIsChinese;

//根据语言设置显示的城市为中文还是英文
//城市选择
+ (NSString *)currentLanguageWithMyChooseCity:(MyCity *)city;

//获取字符串首字母(传入汉字字符串, 返回大写拼音首字母)
//传入英文shangHai，返回的是将首字母改为大写Shanghai，传入的是汉字上海，返回的则是Shang Hai，中间有空格
+ (NSString *)getFirstLetterFromString:(NSString *)aString;

//将汉字转为拼音
+ (NSString *)transform:(NSString *)chinese;

@end
