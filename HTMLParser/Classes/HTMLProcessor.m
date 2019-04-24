//
//  HTMLProcessor.m
//  UAFootball
//
//  Created by Woxapp on 02.11.17.
//  Copyright © 2017 woxapp. All rights reserved.
//

#import "HTMLProcessor.h"

@interface HTMLProcessor()

@property NSString *content;
@property NSString *backgroundColor;

@end

@implementation HTMLProcessor

- (id)init:(NSString *)html {
    _content = html;
    return [super init];
}

- (NSInteger)screenWidth {
    return (NSInteger)[[UIScreen mainScreen] bounds].size.width;
}

- (NSString *)bgColor {
    return _backgroundColor == nil ? @"rgb(255, 255, 255)" : _backgroundColor;
}

- (NSArray *)tags {
    return _supportedTags != nil ? _supportedTags : [@"strong|em|img|h1|h2|h3|h4|h5|h6|p|b|i|hr|ul|ol|dl|dt|dd|div|br|table|tbody|td|th|tr|tt|u|a|iframe|li" componentsSeparatedByString:@"|"];
}

- (NSString *)html {
    return @"<!DOCTYPE html><html><head><style>\(HTMLProcessor.css(backgroundColor))</style></head><body>\(body())</body></html>";
}

- (NSDictionary *)templates {
    return @{@"<(.*?)style=\"(.*?)\"(.*?)>" : @"<$1$3>", @"<(.*?)align=\"(.*?)\"(.*?)>" : @"<$1$3>", @"<img(.*?)align=\".*?\"(.*?)>" : @"<img$1$2>", @"<img(.*?)>" : @"<img align=\"middle\"$1>", @"<table(.*?)>" : @"<table align=\"center\"$1>", @"<iframe(.|\n|\r)*?src=\"https://www.youtube.com/embed/(.*?)\"(.|\n|\r)*?>(.|\n|\r)*?</iframe>" : @"<img src=\"http://img.youtube.com/vi/$2/0.jpg\"/>", @"<iframe(.|\n|\r)*?src=\"http://www.youtube.com/embed/(.*?)\"(.|\n|\r)*?>(.|\n|\r)*?</iframe>" : @"<img src=\"http://img.youtube.com/vi/$2/0.jpg\"/>", @"<iframe(.*?)width=\"(.*?)\"(.*?)</iframe>" : @"<iframe$1width=\"\(screenWidth - 20)\"$3</iframe>", @"<li(.*?)>(.*?)</li>" : @"<li><span style=\"color:black\">$2</span></li>"};
}

- (NSArray *)expressions {
    return @[@"<(.|\n)*?>", @"<iframe((.|\n|\r)*?)>((.|\n|\r)*?)</iframe>"];
}

#pragma mark - Class functions

- (NSString *)css:(NSString *)color {
    if (color) _backgroundColor = color;
    if (_styles != nil) return _styles;
    NSMutableString *css = [[NSMutableString alloc] initWithString:@"table, img { max-width: \(screenWidth - 20)px; border-collapse: collapse; }"];
    [css appendString:@" body { max-width: \(screenWidth - 20)px; background-color: \(bgColor); word-wrap: break-word;}"];
    [css appendString:@" i, em { font-style: italic; }"];
    [css appendString:@" u, li, tt, b, strong, i, em, ul, ol, dl, dt, dd { font-size: 13px; }"];
    [css appendString:@" th, td { text-align: left; font-size: 13px; }"];
    [css appendString:@" p { font-size: 13px; }"];
    [css appendString:@" h1 { font-size: 18px; }"];
    [css appendString:@" h2 { font-size: 15px; }"];
    [css appendString:@" h3 { font-size: 12px; }"];
    [css appendString:@" h4 { font-size: 10px; }"];
    [css appendString:@" h5 { font-size: 9px; }"];
    [css appendString:@" h6 { font-size: 7px; }"];
    [css appendString:@" li, a { color: rgb(255, 156, 0); font-style: bold}"];
    [css appendString:@" dd { color: rgb(151, 151, 151); }"];
    [css appendString:@" th, td, p, u, li, tt, b, strong, i, em, ul, ol, dl, dt, dd, h1, h2, h3, h4, h5, h6 { font-family: \'Helvetica Neue\';}"];
    return css;
}

- (NSString *)body {
    _content = [_content stringByReplacingHTMLEntities];
    NSMutableString *copy = [_content mutableCopy];
    [copy replaceOccurrencesOfString:@"\r\n" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, copy.length)];
    [copy replaceOccurrencesOfString:@"?autoplay=1" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, copy.length)];
    NSError *error;
    NSArray *expressions = [self expressions];
    NSRegularExpression *expression = [NSRegularExpression new];
    NSMutableArray *ranges = [NSMutableArray new];
    for(NSString *exp in expressions) {
        expression = [NSRegularExpression regularExpressionWithPattern:exp options:NSRegularExpressionCaseInsensitive error:&error];
        [ranges addObjectsFromArray:[expression matchesInString:copy options:NSMatchingReportProgress range:NSMakeRange(0, copy.length)]];
    }
    for (NSTextCheckingResult *result in [[ranges reverseObjectEnumerator] allObjects]) {
        [copy stringByReplacingCharactersInRange:[result range] withString:@""];
    }
    NSDictionary *templates = [self templates];
    for (NSString *key in [templates allKeys]) {
        expression = [NSRegularExpression regularExpressionWithPattern:key options:NSRegularExpressionCaseInsensitive error:&error];
        [expression replaceMatchesInString:copy options:NSMatchingReportProgress range:NSMakeRange(0, copy.length) withTemplate:[templates objectForKey: key]];
    }
    return copy;
}



@end
