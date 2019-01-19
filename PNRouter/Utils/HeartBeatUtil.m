//
//  HeartBeatUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "HeartBeatUtil.h"
#import "UserConfig.h"
#import "SocketMessageUtil.h"


dispatch_source_t _timer;

@interface HeartBeatUtil ()

//@property (nonatomic, strong) NSTimer *timer;

@end

@implementation HeartBeatUtil

singleton_implementation(HeartBeatUtil)


/**
 开启vpn连接定时扣费
 */
+ (void) start
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC); // 开始时间
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),30*NSEC_PER_SEC, 0); //每30秒执行
    dispatch_source_set_event_handler(_timer, ^{
        //[TransferUtil sendFundsRequestWithType:3 withVPNInfo:[TransferUtil currentConnectVPNInfo]];
        [HeartBeatUtil heartBeat];
    });
    dispatch_resume(_timer);
}


//+ (void)start {
//    HeartBeatUtil *heartBeatUtil = HeartBeatUtil.sharedHeartBeatUtil;
//    if (!heartBeatUtil.timer) {
//        heartBeatUtil.timer = [NSTimer scheduledTimerWithTimeInterval:30 target:heartBeatUtil selector:@selector(heartBeat) userInfo:nil repeats:YES];
//        [[NSRunLoop currentRunLoop] addTimer:heartBeatUtil.timer forMode:NSRunLoopCommonModes];
//    }
//}

+ (void)stop {
//    HeartBeatUtil *heartBeatUtil = HeartBeatUtil.sharedHeartBeatUtil;
//    if (heartBeatUtil.timer) {
//        [heartBeatUtil.timer invalidate];
//        heartBeatUtil.timer = nil;
//    }
    if (_timer) {
        dispatch_cancel(_timer);
    }
    
}

+ (void)heartBeat {
    UserConfig *userM = [UserConfig getShareObject];
    if (userM.userId && userM.userId.length >0) {
        NSDictionary *params = @{@"Action":@"HeartBeat",@"UserId":userM.userId?:@""};
        [SocketMessageUtil sendVersion1WithParams:params];
    }
   
}

@end
