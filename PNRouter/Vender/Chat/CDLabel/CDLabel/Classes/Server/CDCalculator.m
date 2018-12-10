//
//  CDCalculator.m
//  CDLabel
//
//  Created by chdo on 2018/6/28.
//

#import "CDCalculator.h"
//#import <CommonCrypto/CommonDigest.h>
// #import <CDDevUtility/CDDevuUtilty.h>

@interface CDCalculator()

//@property(nonatomic, strong) dispatch_queue_t calQue;
@property(nonatomic, strong) NSOperationQueue *calQue;
@property(nonatomic, strong) NSBlockOperation *lastOperation;
@property(nonatomic, strong) NSCache *cachedData; // 采用NSCache缓存CTData，防止内存问题
@end

@implementation CDCalculator

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static CDCalculator *single;
    
    dispatch_once(&onceToken, ^{
        single = [[CDCalculator alloc] init];
        single.cachedData = [[NSCache alloc] init];
//        single.calQue = dispatch_queue_create("CDLabel_CDCalculator_queue", DISPATCH_QUEUE_SERIAL);
        single.calQue = [[NSOperationQueue alloc] init];
        single.calQue.name = @"CDLabel_CDCalculator_queue";
        single.calQue.maxConcurrentOperationCount = 6;
    });
    return single;
}

-(void)calcuate:(NSString *)text
            and:(CGSize)containSize
            and:(CTDataConfig)config
{
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
//        NSString *dataId = [NSString stringWithFormat:@"%@%@",[self md5:text],CTDataConfigIdentity(config)];
        NSString *dataId = [NSString stringWithFormat:@"%@%@",text,CTDataConfigIdentity(config)];
        CTData *data = [CDCalculator.share.cachedData objectForKey:dataId];
        
        if (data) {
            if (self.calComplete && self.label) { // 检查是否取消计算回调
                self.calComplete(data);
            }
        } else {
            CTData *data = [CTData dataWithStr:text containerWithSize:containSize configuration:config];
            [CDCalculator.share.cachedData setObject:data forKey:dataId];
            if (self.calComplete && self.label) { // 检查是否取消计算回调
                self.calComplete(data);
            }
        }
    }];
    
    // 优先处理当前任务
    [CDCalculator.share.lastOperation addDependency:operation];
    [CDCalculator.share.calQue addOperation:operation];
    CDCalculator.share.lastOperation = operation;
}

-(void)calcuate:(NSAttributedString *)text
            and:(CGSize)containSize
{
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSString *dataId = [NSString stringWithFormat:@"%@",text.string];
        CTData *data = [CDCalculator.share.cachedData objectForKey:dataId];
        
        if (data) {
            if (self.calComplete && self.label) { // 检查是否取消计算回调
                self.calComplete(data);
            }
        } else {
            CTData *data = [CTData dataWithAttriStr:text containerWithSize:containSize];
            [CDCalculator.share.cachedData setObject:data forKey:dataId];
            if (self.calComplete && self.label) { // 检查是否取消计算回调
                self.calComplete(data);
            }
        }
    }];
    
    // 优先处理当前任务
    [CDCalculator.share.lastOperation addDependency:operation];
    [CDCalculator.share.calQue addOperation:operation];
    CDCalculator.share.lastOperation = operation;
}

//- (NSString *)md5:(NSString *)str
//{
//    const char *cStr = [str UTF8String];
//    unsigned char result[16];
//    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
//    return [NSString stringWithFormat:
//            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//            result[0], result[1], result[2], result[3],
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]
//            ];
//}

@end
