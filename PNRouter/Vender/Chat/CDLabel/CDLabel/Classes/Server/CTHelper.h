//
//  CTHelper.h
//  CDLabel
//
//  Created by chdo on 2017/12/4.
//


#import <UIKit/UIKit.h>
@interface CTHelper : NSObject
@property(nonatomic, class, readonly, strong) CTHelper *share;

#pragma mark 环境
/**
 环境  // 0 调试 1 生产
 */
@property (assign, nonatomic) int environment;
/**
 配置表情字典  emjDic 表情名->image
 */
@property(nonatomic, strong) NSDictionary<NSString*, UIImage *> *emojDic;

@end
