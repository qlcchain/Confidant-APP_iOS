//
//  ToxPullFileTimerUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "ToxPullFileTimerUtil.h"
#import "NSDate+Category.h"
#import "ChatListDataUtil.h"

@implementation ToxPullFileTimerUtil
- (instancetype) init
{
    if (self = [super init]) {
       // [self startTimer];
    }
    return self;
}
- (void) startTimer
{
    @weakify_self
    _timer= [NSTimer scheduledTimerWithTimeInterval:3.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSTimeInterval seconds = [weakSelf.date timeIntervalSinceDate:[NSDate date]];
        if (seconds > 3) {
            [weakSelf cancelTimer];
        }
    }];
}

- (void) cancelTimer
{
    [_timer invalidate];
    _timer = nil;
    NSString *fileNames = [[ChatListDataUtil getShareObject].fileNameParames objectForKey:self.fileKey];
    [[ChatListDataUtil getShareObject].pullTimerDic removeObjectForKey:self.fileKey];
    NSArray *array = [fileNames componentsSeparatedByString:@":"];
    NSArray *resultArr = @[array[0],array[1],@"0"];
    [[NSNotificationCenter defaultCenter] postNotificationName:REVER_FILE_PULL_SUCCESS_NOTI object:@{self.fileKey:resultArr}];
}

@end
