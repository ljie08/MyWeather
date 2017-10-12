//
//  NSString+Languge.m
//  MyWeather
//
//  Created by lijie on 2017/8/3.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "NSString+Languge.h"
#import <CoreLocation/CoreLocation.h>

@implementation NSString (Languge)

//当前语言是中文还是英文
+ (BOOL)currentLanguageIsChinese {
    //获取当前系统语言
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSArray * allLanguages = [defaults objectForKey:@"AppleLanguages"];
    NSString * preferredLang = [allLanguages objectAtIndex:0];
    if ([preferredLang hasPrefix:@"zh"]) {
        return YES;
    } else {
        return NO;
    }
}

//根据语言设置显示的城市为中文还是英文

//城市选择
+ (NSString *)currentLanguageWithMyChooseCity:(MyCity *)city {
    BOOL isChinese = [NSString currentLanguageIsChinese];
    if (isChinese) {
        return city.shortName;
    } else {
        return city.pinyin;
    }
}

//获取字符串首字母(传入汉字字符串, 返回大写拼音首字母)
//传入英文shangHai，返回的是将首字母改为大写Shanghai，传入的是汉字上海，返回的则是Shang Hai，中间有空格
+ (NSString *)getFirstLetterFromString:(NSString *)aString {
    //转成了可变字符串
    NSMutableString *str = [NSMutableString stringWithString:aString];
    //先转换为带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformMandarinLatin,NO);
    //再转换为不带声调的拼音
    CFStringTransform((CFMutableStringRef)str,NULL, kCFStringTransformStripDiacritics,NO);
    //转化为大写拼音
    NSString *strPinYin = [str capitalizedString];
    //获取并返回首字母为大写的字符串
    return strPinYin;
}

//将汉字转为拼音
+ (NSString *)transform:(NSString *)chinese {
    NSMutableString *pinyin = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    NSLog(@"%@", pinyin);
    if ([pinyin rangeOfString:@" "].location !=NSNotFound) {
        NSRange range = [pinyin rangeOfString:@" "];
        [pinyin deleteCharactersInRange:range];
    }
//    NSString *py = [NSString stringWithFormat:@"%@", pinyin];
//    NSString *nilStr = @" ";
//    [py stringByReplacingOccurrencesOfString:nilStr withString:@""];
    return [pinyin lowercaseString];
}



@end
